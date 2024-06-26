import { media } from '@kit.MediaKit';

class AVPlayerManager {
  private avPlayer: media.AVPlayer | null = null
  private loop: boolean = false
  private rawFdPath: string = ''

  async getAVPlayerInstance() {
    // 如果已存在，直接返回
    if (this.avPlayer !== null) {
      return this.avPlayer
    }
    // 初始化播放器
    const player = await media.createAVPlayer()
    player.on('stateChange', (state) => {
      switch (state) {
        case 'initialized':
          player.prepare()
          break;
        case 'prepared':
          player.play()
          break;
        case 'playing':
          player.play()
          break;
        case 'paused':
          player.pause()
          break;
        case 'completed':
          if (this.loop === true) {
            player.play() // 播放结束继续播放：循环播放
          } else {
            player.stop() // 播放结束
          }
          break;
        case 'stopped':
          player.reset() // stop 时 reset -> 释放音频资源
          break;
        default:
          break;
      }
    })
    this.avPlayer = player
    return this.avPlayer
  }

  // 加载 src/main/resources/rawfile 的文件
  async playByRawSrc(rawFdPath: string) {
    const player = await this.getAVPlayerInstance()
    // 先释放原来的资源
    await player.reset()
    // 获取文件信息
    const context = getContext()
    // 加载 src/main/resources/rawfile 文件夹中的文件
    const fileDescriptor = await context.resourceManager.getRawFd(rawFdPath)
    // 设置播放路径
    player.fdSrc = fileDescriptor
    // 播放
    player.play()
  }

  // 停止播放
  async stop() {
    const player = await this.getAVPlayerInstance()
    this.loop = false
    player.stop()
  }

  // 设置循环播放
  async setLoop(isLoop: boolean) {
    this.loop = isLoop
  }
}

export const avPlayerManager = new AVPlayerManager()