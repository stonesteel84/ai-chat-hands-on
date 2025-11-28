import { NextRequest } from 'next/server'
import { supabase } from '@/lib/supabase/client'

export async function GET(request: NextRequest) {
    try {
        const url = new URL(request.url)
        const sessionId = url.searchParams.get('sessionId')

        if (!sessionId) {
            return Response.json(
                {
                    success: false,
                    error: 'sessionId가 필요합니다.'
                },
                { status: 400 }
            )
        }

        // 메시지 로드
        const { data, error } = await supabase
            .from('messages')
            .select('*')
            .eq('session_id', sessionId)
            .order('created_at', { ascending: true })

        if (error) {
            console.error('메시지 로드 오류:', error)
            return Response.json(
                {
                    success: false,
                    error: `메시지 로드 실패: ${error.message}`
                },
                { status: 500 }
            )
        }

        // DB 형식을 클라이언트 형식으로 변환
        const messages = (data || []).map(msg => ({
            role: msg.role as 'user' | 'assistant',
            content: msg.content,
            imageUrl: msg.image_url || undefined,
            functionCalls: msg.function_calls || undefined,
            functionResults: msg.function_results || undefined
        }))

        return Response.json({
            success: true,
            messages
        })
    } catch (error) {
        console.error('메시지 로드 API 오류:', error)
        return Response.json(
            {
                success: false,
                error:
                    error instanceof Error
                        ? error.message
                        : '알 수 없는 오류가 발생했습니다'
            },
            { status: 500 }
        )
    }
}

