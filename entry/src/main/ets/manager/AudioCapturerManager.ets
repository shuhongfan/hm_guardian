import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { permissionManager } from '.'
import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit'

// 停止录音采集时，返回录音文件关键信息
interface AudioInfo {
  filePath: string // 文件路径
  date_added: number // 创建时间
  duration: number // 持续时长
}

class AudioCapturerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.MICROPHONE"]
  // 音频流配置
  private audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
    channels: audio.AudioChannel.CHANNEL_2, // 通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
  };
  // 音频采集器配置
  private audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  };
  // 音频采集器实例
  private audioCapturer: audio.AudioCapturer | null = null
  // 采集录音的文件路径
  private filePath: string = ''
  // 添加时间戳
  private date_added: number = 0
  // 音频渲染器配置
  private audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_MOVIE, // 播放类型，MOVIE 表示用喇叭播放
    rendererFlags: 0
  };
  // 音频渲染器实例
  private audioRenderer: audio.AudioRenderer | null = null

  // 初始化权限
  async requestPermissions() {
    // 申请权限
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启弹窗提示
      promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '录音功能需要获取权限，请在系统设置中打开麦克风开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
        .then((res) => {
          // 打开设置页
          if (res.index === 1) {
            permissionManager.openPermissionSettingsPage()
          }
        })
    }
  }

  // 创建/获取音频采集器
  async getAudioCapturer() {
    if (this.audioCapturer) {
      return this.audioCapturer
    }
    this.audioCapturer = await audio.createAudioCapturer({
      streamInfo: this.audioStreamInfo,
      capturerInfo: this.audioCapturerInfo
    })
    return this.audioCapturer
  }

  // 开始录音采集
  async startRecorder(filePath: string) {
    // 保存 文件路径 和 时间戳
    this.filePath = filePath
    this.date_added = Date.now()
    //  1) 打开文件，注意设置模式
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    // 1. 创建音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 2. 订阅(读取音频采集器的数据流，写入到打开的文件中)
    audioCapturer.on('readData', (buffer) => {
      //  2) 把 buffer 数据流，写入到打开的文件中
      fileIo.writeSync(file.fd, buffer)
    })
    // 3. 开始
    audioCapturer.start()
  }

  // 结束录音采集
  async stopRecorder(): Promise<AudioInfo> {
    // 获取音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 1. 停止录音
    await audioCapturer.stop()
    // 2. 释放资源和硬件占用
    audioCapturer.release()
    // 3. 释放变量，对象重新赋值为 null，可以被 垃圾回收机制 自动清理
    this.audioCapturer = null
    // 停止录音采集时，返回录音文件关键信息
    return {
      filePath: this.filePath,
      date_added: this.date_added,
      duration: Date.now() - this.date_added
    }
  }

  // 获取音频渲染器（播放器）
  async getAudioRenderer() {
    if (this.audioRenderer) {
      return this.audioRenderer
    }
    this.audioRenderer = await audio.createAudioRenderer({
      streamInfo: this.audioStreamInfo,
      rendererInfo: this.audioRendererInfo
    })
    return this.audioRenderer
  }

  // 播放录音
  async startRenderer(filePath: string) {
    //  1) 根据路径打开文件，获取文件信息
    const file = fileIo.openSync(filePath)
    const stat = fileIo.statSync(file.fd)
    // 1. 获取音频渲染器（播放器）
    const audioRenderer = await this.getAudioRenderer()
    //  2) 准备累加值，用于自动停止
    let bufferSize: number = 0
    // 2. 调用on('writeData')方法，订阅监听音频数据写入回调
    audioRenderer.on('writeData', (buffer) => {
      // 3) 把 buffer 信息写入到音频渲染器中
      fileIo.readSync(file.fd, buffer)
      // 获取文件信息，如果读取时已经超出文件大小，自动停止
      bufferSize += buffer.byteLength
      if (bufferSize >= stat.size) {
        audioRenderer.stop() // 停止渲染器(播放器)
        audioRenderer.release() // 释放资源(硬件)
        this.audioRenderer = null // 释放变量
      }
    })
    // 3. 启动音频渲染器（播放器）
    audioRenderer.start()
  }

  // 停止播放录音
  async stopRenderer() {
    // 获取音频渲染器（播放器）
    const audioRenderer = await this.getAudioRenderer()
    // RUNNING 和 PAUSED 状态下才能 stop，stop 后自动 release 释放资源(硬件)
    if ([audio.AudioState.STATE_RUNNING, audio.AudioState.STATE_PAUSED].includes(this.audioRenderer!.state)) {
      await audioRenderer.stop() // 停止渲染(播放)
      audioRenderer.release() // 释放资源(硬件)
      this.audioRenderer = null // 释放变量
    }
  }
}

export const audioCapturerManager = new AudioCapturerManager()