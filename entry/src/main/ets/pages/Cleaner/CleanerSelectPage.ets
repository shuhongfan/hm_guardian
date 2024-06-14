import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { NavigationTitleBuilder } from '../../common/builders'
import { formatByteLength } from '../../common/utils'
import { cleanerManager, themeManager } from '../../manager'
import { promptAction, router } from '@kit.ArkUI'

interface RouterParams {
  name: string
}

@Entry
@Component
struct CleanerSelectPage {
  @State routerParams: RouterParams | null = null
  @State list: photoAccessHelper.PhotoAsset[] = []
  @State @Watch('onSelectedChange') selectedUris: string[] = []
  @State selectedSize: number = 0

  aboutToAppear() {
    // 获取页面参数
    const params = router.getParams() as RouterParams
    if (params) {
      // 保存路由参数
      this.routerParams = params
      // 获取图片列表
      this.getList()
    }
  }

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  // 获取图片列表
  async getList() {
    if (this.routerParams?.name === '屏幕截图') {
      // 获取屏幕截图
      this.list = await cleanerManager.getScreenshotList()
    }
  }

  // 当选择按钮发生变化时，计算节省空间大小
  onSelectedChange() {
    // 根据选中的 uri 过滤出选中的图片资源
    const selectedList = this.list.filter(item => this.selectedUris.includes(item.uri))
    // 通过 reduce 累加文件大小
    this.selectedSize = selectedList.reduce((acc, v) => v.get(photoAccessHelper.PhotoKeys.SIZE) as number + acc, 0)
  }

  // 删除图片
  async deletePhotos() {
    // 删除选中的图片
    await cleanerManager.deletePhotos(this.selectedUris)
    // 成功轻提示
    promptAction.showToast({ message: '删除成功，共节省' + formatByteLength(this.selectedSize) })
    // 获取获取图片列表，注意 ForEach 更新问题
    // JSON.stringify(PhotoAsset) 会得到 {} 空对象，导致 ForEach 无法生成唯一标识
    // 需通过 ForEach 的第三个参数，指定唯一标识
    this.getList()
  }

  build() {
    Navigation() {
      Column() {
        Column({ space: 10 }) {
          Text() {
            Span('可节省')
            Span(formatByteLength(this.selectedSize))
          }
          .fontSize(16)
          .fontColor($r('app.color.white'))

          Text(`已选择${this.selectedUris.length}张`)
            .fontSize(12)
            .fontColor($r('app.color.white'))
        }
        .justifyContent(FlexAlign.Center)
        .height(66)

        Scroll() {
          Column() {
            GridRow({ columns: 4, gutter: 8 }) {
              ForEach(this.list, (asset: photoAccessHelper.PhotoAsset) => {
                GridCol() {
                  Stack({ alignContent: Alignment.TopStart }) {
                    if (asset.photoType === photoAccessHelper.PhotoType.IMAGE) {
                      // 图片
                      Image(asset.uri)
                        .width('100%')
                        .aspectRatio(1)
                        .borderRadius(6)
                    } else if (asset.photoType === photoAccessHelper.PhotoType.VIDEO) {
                      // 视频
                      Video({ src: asset.uri })
                        .width('100%')
                        .aspectRatio(1)
                        .borderRadius(6)
                        .autoPlay(true)
                        .muted(true)
                        .controls(false)
                    }
                    Checkbox({ name: asset.uri })
                  }
                  .width('100%')
                  .aspectRatio(1)
                }

                // JSON.stringify(PhotoAsset) 会得到 {} 空对象，导致 ForEach 无法生成唯一标识
                // 通过第三个参数，把唯一标识调整为 item.uri
              }, (item: photoAccessHelper.PhotoAsset) => item.uri)
            }

            Blank()
              .layoutWeight(1)
          }
          .padding(15)
        }
        .height('100%')
        .backgroundColor($r('app.color.white'))
      }
      .width('100%')
      .layoutWeight(1)

      Row({ space: 10 }) {
        Column() {
          CheckboxGroup()
            .onChange((event) => {
              this.selectedUris = event.name
            })
          Text('全选')
            .fontColor($r('app.color.font2'))
            .fontSize(12)
        }

        Button('删除')
          .type(ButtonType.Normal)
          .borderRadius(10)
          .layoutWeight(1)
          .height(42)
          .backgroundColor($r('app.color.danger'))
          .onClick(() => {
            // TODO：删除选中图片
            this.deletePhotos()
          })
      }
      .border({ width: { top: 1 }, color: $r('app.color.border') })
      .width('100%')
      .height(76)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.white'))
    }
    .title(NavigationTitleBuilder(this.routerParams?.name))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.3], [$r('app.color.white'), 0.3]]
    })
  }
}