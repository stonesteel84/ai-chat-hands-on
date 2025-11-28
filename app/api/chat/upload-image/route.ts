import { NextRequest } from 'next/server'
import { supabase } from '@/lib/supabase/client'

const BUCKET_NAME = 'chat-images'

export async function POST(request: NextRequest) {
    try {
        const { imageData, mimeType } = await request.json()

        if (!imageData) {
            return Response.json(
                { success: false, error: '이미지 데이터가 필요합니다.' },
                { status: 400 }
            )
        }

        // Base64 데이터에서 실제 데이터 추출
        const base64Data = imageData.includes(',')
            ? imageData.split(',')[1]
            : imageData

        // MIME 타입에서 확장자 추출
        const extension = mimeType?.split('/')[1] || 'png'
        const fileName = `${Date.now()}-${Math.random()
            .toString(36)
            .substring(7)}.${extension}`

        // Base64를 Buffer로 변환
        const buffer = Buffer.from(base64Data, 'base64')

        // Supabase Storage에 업로드
        const { data, error } = await supabase.storage
            .from(BUCKET_NAME)
            .upload(fileName, buffer, {
                contentType: mimeType || 'image/png',
                upsert: false
            })

        if (error) {
            console.error('Supabase Storage 업로드 오류:', error)
            return Response.json(
                {
                    success: false,
                    error: `이미지 업로드 실패: ${error.message}`
                },
                { status: 500 }
            )
        }

        // 공개 URL 가져오기
        const {
            data: { publicUrl }
        } = supabase.storage.from(BUCKET_NAME).getPublicUrl(fileName)

        return Response.json({
            success: true,
            url: publicUrl,
            fileName: data.path
        })
    } catch (error) {
        console.error('이미지 업로드 API 오류:', error)
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

