import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
    // 도커 배포를 위한 standalone 출력
    output: 'standalone',
    experimental: {
        serverComponentsExternalPackages: ['@modelcontextprotocol/sdk']
    },
    webpack: (config, { isServer }) => {
        if (!isServer) {
            // 클라이언트에서 Node.js 전용 모듈 제외
            config.resolve.fallback = {
                ...config.resolve.fallback,
                fs: false,
                child_process: false,
                crypto: false,
                os: false,
                path: false,
                stream: false
            }
        }
        return config
    }
}

export default nextConfig
