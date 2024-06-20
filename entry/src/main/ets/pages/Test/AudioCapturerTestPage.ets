import { permissionManager } from '../../manager/PermissionManager'

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