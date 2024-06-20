import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { permissionManager } from '.'
import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit'

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
  async stopRecorder() {
    // 获取音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 1. 停止录音
    await audioCapturer.stop()
    // 2. 释放资源和硬件占用
    audioCapturer.release()
    // 3. 释放变量，对象重新赋值为 null，可以被 垃圾回收机制 自动清理
    this.audioCapturer = null
  }
}

export const audioCapturerManager = new AudioCapturerManager()