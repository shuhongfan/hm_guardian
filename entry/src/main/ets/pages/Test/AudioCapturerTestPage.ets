import { permissionManager } from '../../manager/PermissionManager'
import { audio } from '@kit.AudioKit'

/**
 * 如何选择音频录制开发方式
 *   ArkTS/JS API
 *    1. AudioCapturer  PCM格式、适用于更专业、更多样化的媒体录制应用开发(如：音频通话)
 *    2. AVRecorder     生成m4a文件、支持音频编码（m4a、aac、mp3、ogg、wav、flac）
 *
 *   Native API（C/C++ 不考虑）
 */
@Entry
@Component
struct AudioCapturerTestPage {
  @State isGrant: boolean = false

  aboutToAppear() {
    this.requestPermissions()
  }

  async requestPermissions() {
    // 音频开发：需要申请麦克风权限
    this.isGrant = await permissionManager.requestPermissions(['ohos.permission.MICROPHONE'])
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Text('麦克风权限是否开启：' + this.isGrant)
          Button('1. 创建AudioCapturer实例-配置音频采集参数')
            .onClick(() => {
              // 音频流信息
              const audioStreamInfo: audio.AudioStreamInfo = {
                samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
                channels: audio.AudioChannel.CHANNEL_2, // 通道
                sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
                encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
              };

              // 音频采集器信息
              const audioCapturerInfo: audio.AudioCapturerInfo = {
                source: audio.SourceType.SOURCE_TYPE_MIC, // 声音来源
                capturerFlags: 0, // 0 代表普通音频采集器，1 代表低时延音频采集器 (ArkTS接口暂不支持低时延音频采集器)
              };

              // createAudioCapturer 创建音频采集器时的必传参数
              const audioCapturerOptions: audio.AudioCapturerOptions = {
                streamInfo: audioStreamInfo, // 音频流信息
                capturerInfo: audioCapturerInfo, // 音频采集器信息
              };

              // 创建音频采集器
              audio.createAudioCapturer(audioCapturerOptions, (err, data) => {
                if (err) {
                  console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
                } else {
                  console.info('Invoke createAudioCapturer succeeded.');
                  let audioCapturer = data;
                }
              });
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('音频录制开发')
    .titleMode(NavigationTitleMode.Mini)
  }
}