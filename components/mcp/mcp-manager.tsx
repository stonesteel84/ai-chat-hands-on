'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle
} from '@/components/ui/card'
// import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Plus, AlertTriangle, Download, Upload } from 'lucide-react'
import { MCPServerForm } from './mcp-server-form'
import { MCPServerList } from './mcp-server-list'
import { MCPServerDetails } from './mcp-server-details'
import { MCPServerStorage } from '@/lib/mcp/storage'
import { MCPServerConfig, ConnectedMCPServer } from '@/lib/types/mcp'
import { mcpClientManager } from '@/lib/mcp/client'
import { useMCP } from '@/lib/contexts/mcp-context'
import { toast } from '@/components/ui/use-toast'

type View = 'list' | 'form' | 'details'

export function MCPManager() {
    const { connectedServers, setConnectedServers, refreshConnections } =
        useMCP()
    const [servers, setServers] = useState<MCPServerConfig[]>([])
    const [currentView, setCurrentView] = useState<View>('list')
    const [editingServer, setEditingServer] = useState<MCPServerConfig | null>(
        null
    )
    const [selectedServer, setSelectedServer] =
        useState<ConnectedMCPServer | null>(null)
    const [isLoading, setIsLoading] = useState(false)

    // localStorage에서 서버 목록 로드
    useEffect(() => {
        const loadedServers = MCPServerStorage.getAllServers()
        setServers(loadedServers)

        // 컨텍스트에서 연결 상태 새로고침
        refreshConnections()
    }, [refreshConnections])

    const handleAddServer = () => {
        setEditingServer(null)
        setCurrentView('form')
    }

    const handleEditServer = (server: MCPServerConfig) => {
        setEditingServer(server)
        setCurrentView('form')
    }

    const handleSaveServer = async (config: MCPServerConfig) => {
        setIsLoading(true)
        try {
            // localStorage에 저장
            MCPServerStorage.saveServer(config)

            // 상태 업데이트
            setServers(MCPServerStorage.getAllServers())
            setCurrentView('list')

            toast({
                title: '서버 저장 완료',
                description: `${config.name} 서버가 저장되었습니다.`
            })
        } catch (error) {
            toast({
                title: '서버 저장 실패',
                description:
                    error instanceof Error
                        ? error.message
                        : '알 수 없는 오류가 발생했습니다.',
                variant: 'destructive'
            })
        } finally {
            setIsLoading(false)
        }
    }

    const handleDeleteServer = async (serverId: string) => {
        try {
            // 연결된 서버라면 먼저 연결 해제
            const connectedServer = connectedServers.find(
                cs => cs.config.id === serverId
            )
            if (connectedServer?.isConnected) {
                await handleDisconnectServer(serverId)
            }

            MCPServerStorage.deleteServer(serverId)
            setServers(MCPServerStorage.getAllServers())

            toast({
                title: '서버 삭제 완료',
                description: '서버가 삭제되었습니다.'
            })
        } catch (error) {
            toast({
                title: '서버 삭제 실패',
                description:
                    error instanceof Error
                        ? error.message
                        : '알 수 없는 오류가 발생했습니다.',
                variant: 'destructive'
            })
        }
    }

    const handleConnectServer = async (server: MCPServerConfig) => {
        setIsLoading(true)
        try {
            console.log(`${server.name} 서버에 연결을 시도합니다...`)
            console.log('서버 설정:', {
                id: server.id,
                name: server.name,
                transport: server.transport,
                command: server.command,
                url: server.url
            })

            const connectedServer = await mcpClientManager.connectServer(server)

            const updatedServers = connectedServers.filter(
                cs => cs.config.id !== server.id
            )
            setConnectedServers([...updatedServers, connectedServer])

            MCPServerStorage.updateServerStatus(
                server.id,
                connectedServer.isConnected
            )
            setServers(MCPServerStorage.getAllServers())

            // 연결 상태 새로고침
            refreshConnections()

            if (connectedServer.isConnected) {
                toast({
                    title: '서버 연결 성공',
                    description: `${server.name} 서버에 연결되었습니다. Tools: ${connectedServer.tools.length}, Prompts: ${connectedServer.prompts.length}, Resources: ${connectedServer.resources.length}`
                })
            } else {
                const errorMsg =
                    connectedServer.lastError ||
                    '서버 연결에 실패했습니다. 설정을 확인해주세요.'
                console.error('연결 실패 상세:', {
                    server: server.name,
                    error: errorMsg,
                    config: server,
                    transport: server.transport,
                    url: server.url,
                    command: server.command
                })

                // 504 오류에 대한 특별 안내
                if (errorMsg.includes('504') || errorMsg.includes('타임아웃')) {
                    throw new Error(
                        `${errorMsg}\n\n해결 방법:\n1. 서버가 실행 중인지 확인\n2. URL이 올바른지 확인\n3. 방화벽 설정 확인\n4. 네트워크 연결 확인`
                    )
                }

                // invalid_token 에러 발생 시 Smithery 대시보드 확인 및 따옴표 주의 안내 메시지 표시
                if (errorMsg.includes('invalid_token')) {
                    throw new Error(
                        `인증 실패: 토큰이 유효하지 않습니다.\n\n${errorMsg}\n\n해결 방법:\n1. Smithery 대시보드에서 API 토큰이 만료되지 않았는지 확인하세요.\n2. 토큰을 다시 복사하여 'HTTP 헤더'에 입력해주세요.\n3. 입력 예시:\nAuthorization=Bearer eyJhbG...`
                    )
                }

                // 인증 오류에 대한 특별 안내
                if (
                    errorMsg.includes('Authorization header') ||
                    errorMsg.includes('401') ||
                    errorMsg.includes('403')
                ) {
                    throw new Error(
                        `인증 오류: ${errorMsg}\n\n해결 방법:\n1. MCP 서버 목록에서 해당 서버의 '수정' 버튼을 클릭하세요.\n2. 'HTTP 헤더' 필드에 다음 형식으로 토큰을 추가하세요:\nAuthorization=Bearer <YOUR_TOKEN>`
                    )
                }

                throw new Error(errorMsg)
            }
        } catch (error) {
            console.error('MCP 서버 연결 오류:', error)
            const errorMessage =
                error instanceof Error
                    ? error.message
                    : '알 수 없는 오류가 발생했습니다.'

            toast({
                title: '서버 연결 실패',
                description: errorMessage,
                variant: 'destructive'
            })
        } finally {
            setIsLoading(false)
        }
    }

    const handleDisconnectServer = async (serverId: string) => {
        try {
            await mcpClientManager.disconnectServer(serverId)

            setConnectedServers(
                connectedServers.filter(cs => cs.config.id !== serverId)
            )

            MCPServerStorage.updateServerStatus(serverId, false)
            setServers(MCPServerStorage.getAllServers())

            toast({
                title: '서버 연결 해제',
                description: '서버 연결이 해제되었습니다.'
            })
        } catch (error) {
            toast({
                title: '연결 해제 실패',
                description:
                    error instanceof Error
                        ? error.message
                        : '알 수 없는 오류가 발생했습니다.',
                variant: 'destructive'
            })
        }
    }

    const handleViewDetails = (server: ConnectedMCPServer) => {
        setSelectedServer(server)
        setCurrentView('details')
    }

    const handleToolCall = async (
        toolName: string,
        args: Record<string, unknown>
    ) => {
        if (!selectedServer) return

        return await mcpClientManager.callTool(selectedServer.config.id, {
            name: toolName,
            arguments: args
        })
    }

    const handlePromptCall = async (
        promptName: string,
        args: Record<string, unknown>
    ) => {
        if (!selectedServer) return

        return await mcpClientManager.getPromptResult(
            selectedServer.config.id,
            promptName,
            args
        )
    }

    const handleResourceRead = async (uri: string) => {
        if (!selectedServer) return

        return await mcpClientManager.readResource(
            selectedServer.config.id,
            uri
        )
    }

    const handleExportServers = () => {
        try {
            const data = MCPServerStorage.exportServers()
            const blob = new Blob([data], { type: 'application/json' })
            const url = URL.createObjectURL(blob)
            const a = document.createElement('a')
            a.href = url
            a.download = `mcp-servers-${new Date().toISOString().split('T')[0]
                }.json`
            document.body.appendChild(a)
            a.click()
            document.body.removeChild(a)
            URL.revokeObjectURL(url)

            toast({
                title: '내보내기 완료',
                description: '서버 설정이 파일로 내보내졌습니다.'
            })
        } catch {
            toast({
                title: '내보내기 실패',
                description: '서버 설정 내보내기에 실패했습니다.',
                variant: 'destructive'
            })
        }
    }

    const handleImportServers = (
        event: React.ChangeEvent<HTMLInputElement>
    ) => {
        const file = event.target.files?.[0]
        if (!file) return

        const reader = new FileReader()
        reader.onload = e => {
            try {
                const data = e.target?.result as string
                MCPServerStorage.importServers(data)
                setServers(MCPServerStorage.getAllServers())

                toast({
                    title: '가져오기 완료',
                    description: '서버 설정을 가져왔습니다.'
                })
            } catch (error) {
                toast({
                    title: '가져오기 실패',
                    description:
                        error instanceof Error
                            ? error.message
                            : '파일을 읽을 수 없습니다.',
                    variant: 'destructive'
                })
            }
        }
        reader.readAsText(file)

        // input 초기화
        event.target.value = ''
    }

    return (
        <div className="max-w-6xl mx-auto p-6 space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold">MCP 서버 관리</h1>
                    <p className="text-muted-foreground">
                        Model Context Protocol 서버를 등록하고 관리하세요
                    </p>
                </div>
                <div className="flex items-center gap-2">
                    <input
                        type="file"
                        accept=".json"
                        onChange={handleImportServers}
                        className="hidden"
                        id="import-servers"
                    />
                    <Button
                        variant="outline"
                        onClick={() =>
                            document.getElementById('import-servers')?.click()
                        }
                    >
                        <Upload className="w-4 h-4 mr-2" />
                        가져오기
                    </Button>
                    <Button variant="outline" onClick={handleExportServers}>
                        <Download className="w-4 h-4 mr-2" />
                        내보내기
                    </Button>
                </div>
            </div>

            <Alert>
                <AlertTriangle className="h-4 w-4" />
                <AlertDescription>
                    <strong>보안 주의:</strong> 공용 또는 공유 PC에서는 민감한
                    정보(API 키, 인증 토큰 등)를 서버 설정에 저장하지 마세요.
                    모든 데이터는 브라우저 로컬 스토리지에 저장됩니다.
                </AlertDescription>
            </Alert>

            {currentView === 'list' && (
                <Card>
                    <CardHeader>
                        <div className="flex items-center justify-between">
                            <div>
                                <CardTitle>등록된 서버</CardTitle>
                                <CardDescription>
                                    {servers.length}개의 서버가 등록되어
                                    있습니다
                                </CardDescription>
                            </div>
                            <Button onClick={handleAddServer}>
                                <Plus className="w-4 h-4 mr-2" />새 서버 추가
                            </Button>
                        </div>
                    </CardHeader>
                    <CardContent>
                        <MCPServerList
                            servers={servers}
                            connectedServers={connectedServers}
                            onEdit={handleEditServer}
                            onDelete={handleDeleteServer}
                            onConnect={handleConnectServer}
                            onDisconnect={handleDisconnectServer}
                            onViewDetails={handleViewDetails}
                        />
                    </CardContent>
                </Card>
            )}

            {currentView === 'form' && (
                <div className="flex justify-center">
                    <MCPServerForm
                        onSubmit={handleSaveServer}
                        onCancel={() => setCurrentView('list')}
                        initialConfig={editingServer || undefined}
                        isLoading={isLoading}
                    />
                </div>
            )}

            {currentView === 'details' && selectedServer && (
                <div className="space-y-4">
                    <Button
                        variant="outline"
                        onClick={() => setCurrentView('list')}
                    >
                        ← 목록으로 돌아가기
                    </Button>
                    <MCPServerDetails
                        server={selectedServer}
                        onToolCall={handleToolCall}
                        onPromptCall={handlePromptCall}
                        onResourceRead={handleResourceRead}
                    />
                </div>
            )}
        </div>
    )
}
