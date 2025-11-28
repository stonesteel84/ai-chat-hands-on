import { NextRequest } from 'next/server'
import { connectToMCPServer } from '@/lib/actions/mcp-actions'
import { MCPServerConfig } from '@/lib/types/mcp'

export async function POST(request: NextRequest) {
    try {
        const config: MCPServerConfig = await request.json()

        console.log(`🔌 MCP 서버 연결 시도: ${config.name} (${config.id})`)
        console.log(`📋 설정:`, {
            transport: config.transport,
            command: config.command,
            url: config.url,
            hasArgs: !!config.args,
            hasEnv: !!config.env
        })

        const result = await connectToMCPServer(config)

        if (!result.isConnected) {
            console.error(
                `❌ 연결 실패: ${result.lastError || '알 수 없는 오류'}`
            )
            return Response.json(
                {
                    success: false,
                    error: result.lastError || '서버 연결에 실패했습니다',
                    data: result
                },
                { status: 500 }
            )
        }

        console.log(
            `✅ 연결 성공: ${config.name} - Tools: ${result.tools.length}, Prompts: ${result.prompts.length}, Resources: ${result.resources.length}`
        )

        return Response.json({
            success: true,
            data: result
        })
    } catch (error) {
        console.error('MCP 서버 연결 API 오류:', error)
        const errorMessage =
            error instanceof Error
                ? error.message
                : '알 수 없는 오류가 발생했습니다'

        return Response.json(
            {
                success: false,
                error: errorMessage
            },
            { status: 500 }
        )
    }
}

