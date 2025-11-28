import { NextRequest } from 'next/server'
import { supabase } from '@/lib/supabase/client'

export async function POST(request: NextRequest) {
    try {
        const {
            sessionId,
            role,
            content,
            imageUrl,
            functionCalls,
            functionResults
        } = await request.json()

        if (!sessionId || !role || !content) {
            return Response.json(
                {
                    success: false,
                    error: 'sessionId, role, content가 필요합니다.'
                },
                { status: 400 }
            )
        }

        // 메시지 저장
        const { data, error } = await supabase
            .from('messages')
            .insert({
                id: `${Date.now()}-${Math.random().toString(36).substring(7)}`,
                session_id: sessionId,
                role,
                content,
                image_url: imageUrl || null,
                function_calls: functionCalls || null,
                function_results: functionResults || null
            })
            .select()
            .single()

        if (error) {
            console.error('메시지 저장 오류:', error)
            return Response.json(
                {
                    success: false,
                    error: `메시지 저장 실패: ${error.message}`
                },
                { status: 500 }
            )
        }

        return Response.json({
            success: true,
            data
        })
    } catch (error) {
        console.error('메시지 저장 API 오류:', error)
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

