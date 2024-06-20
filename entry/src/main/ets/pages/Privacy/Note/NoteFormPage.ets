// 页面参数
import { privacyNoteDB } from '../../../database'
import { promptAction, router } from '@kit.ArkUI'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

interface RouterParams {
  id?: number
}


// 隐私笔记表单页-负责 新增 和 修改
@Entry
@Component
struct NoteDetailPage {
  // 标题
  @State title: string = ''
  // 内容
  @State content: string = ''
  // 页面参数
  @State routerParams: RouterParams = {}

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as RouterParams
    if (params) {
      // 保存路由参数
      this.routerParams = params
      // 获取笔记详情
      this.getDetail()
    }
  }

  // 获取笔记详情-回显到页面中
  async getDetail() {
    // 根据 id 查找笔记
    const list = await privacyNoteDB.query(this.routerParams.id)
    // 提取出笔记详情
    const detail = list[0]
    // 如果有笔记详情，回显到页面中
    if (detail) {
      this.title = detail.title
      this.content = detail.content
    }
  }

  // 保存(新增/修改)
  async onSubmit() {
    if (this.routerParams.id) {
      // 如果有 id 调用修改 update
      await privacyNoteDB.update({
        id: this.routerParams.id,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    } else {
      // 没有 id 调用新增 insert
      await privacyNoteDB.insert({
        id: null,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    }
    // 等待 await 保存(新增/修改)完成后，返回列表页
    promptAction.showToast({ message: '保存成功' })
    router.back()
  }

  // 当用户点击返回按钮时触发
  onBackPress(): boolean | void {
    // 如果有 id 表示修改，修改时使用默认返回逻辑
    if (this.routerParams.id) { return false }
    // 自己处理返回逻辑
    promptAction.showDialog({
      title: '温馨提示',
      message: '您输入的内容还没有保存，是否放弃？',
      alignment: DialogAlignment.Center,
      buttons: [
        { text: '取消', color: $r('app.color.font_sub') },
        { text: '确定', color: $r('app.color.brand') },
      ]
    })
      .then((res) => {
        if (res.index === 1) {
          // 用户点击了确定时，才返回上一页
          router.back()
        }
      })
    // 阻断默认返回的行为
    return true
  }

  /**
   *  华为系统级别分享 systemShare
   *    1. 华为分享没有开源，只能在 HarmonyOS 文档中查看，在 OpenHarmony 文档中没有。
   *    2. 华为分享需要通过真机测试，模拟器不支持分享(模拟器会闪退)。
   */

  // 分享笔记
  shareNote() {
    // 1. 构建分享数据
    const shareData = new systemShare.SharedData({
      utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, // 指定分享的数据类型
      title: this.title,
      content: this.content
    })
    // 2. 构建分享控制器(显示分享面板，注册分享关闭事件)
    const shareController = new systemShare.ShareController(shareData)
    const context = getContext() as common.UIAbilityContext
    // 显示分享面板
    shareController.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE
    })
    // 监听分享关闭事件
    shareController.on('dismiss', () => {
      promptAction.showToast({ message: '分享成功，可领取奖励' })
    })
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text('保存')
        .fontSize(16)
        .fontColor(this.title.trim() !== '' ? $r('app.color.font') : $r('app.color.font_sub'))
        .enabled(this.title.trim() !== '')
        .onClick(() => {
          // TODO：保存/新增
          this.onSubmit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 10 }) {
          Text('标题')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextInput({ placeholder: '请输入笔记标题', text: this.title })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .padding({ left: 10 })
            .onChange((text) => {
              this.title = text
            })
            .onSubmit(() => {
              // TODO：提交表单(保存/新增)
            })
          Text('内容')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextArea({ placeholder: '请输入笔记内容', text: this.content })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .layoutWeight(1)
            .padding(10)
            .onChange((text) => {
              this.content = text
            })
        }
        .padding({ bottom: 160 })

        if (this.routerParams.id) {
          // 底部按钮
          Row({ space: 10 }) {
            Button('删除')
              .type(ButtonType.Normal)
              .backgroundColor('#FF5E5D')
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：删除
              })
            Button('分享')
              .type(ButtonType.Normal)
              .backgroundColor($r('app.color.brand'))
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：分享
                this.shareNote()
              })
          }
          .padding({ bottom: 80 })
        }
      }
      .padding({ left: 15, right: 15, top: 20 })

    }
    .title('笔记')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())

  }
}