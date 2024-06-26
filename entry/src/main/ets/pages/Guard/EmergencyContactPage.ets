// 紧急联系人
import { getEmergencyContactAPI, postEmergencyContactAPI } from '../../api'
import { promptAction, router } from '@kit.ArkUI'

@Entry
@Component
struct EmergencyContactPage {
  @State name: string = '孙悟空'
  @State phone: string = ''

  // 保存
  async onSubmit() {
    // 提交表单
    await postEmergencyContactAPI({
      name: this.name,
      phone: this.phone
    })
    // 成功提示
    promptAction.showToast({ message: '保存成功' })
    // 返回上一页
    router.back()
  }

  // 页面加载
  aboutToAppear() {
    // 获取并回显紧急联系人
    this.getDetail()
  }

  // 获取紧急联系人详情
  async getDetail() {
    const res = await getEmergencyContactAPI()
    if (res.data.result) {
      // 填充(回显)到表单中
      this.phone = res.data.result.phone
      this.name = res.data.result.name
    }
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text('保存')
        .fontSize(16)
        .fontColor(this.phone && this.name.length > 0 ? $r('app.color.font') : $r('app.color.font_sub'))
        .onClick(() => {
          // TODO：保存提交
          this.onSubmit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  @Builder
  TitleBuilder(title: string, description: string) {
    Column() {
      // 标题
      Row() {
        Divider()
          .backgroundColor('#0C273D')
          .vertical(true)
          .width(4)
          .height(18)
          .borderRadius(3)
          .margin({ right: 10 })
        Text(title)
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.font'))
      }
      .width('100%')

      // 说明
      Text(description)
        .fontSize(12)
        .fontColor($r('app.color.font_sub'))
        .lineHeight(18)
        .margin({ top: 10 })
        .width('100%')
    }
    .padding(20)
    .width('100%')
  }

  build() {
    Navigation() {
      this.TitleBuilder('紧急联系人',
        '在紧急情况下，TA将自动接收您的求助通知并获取您的当前位置及手机电量信息，为您的人身安全保驾护航。')

      Column() {
        Row() {
          Text('姓名')
            .width(50)
            .fontSize(14)
            .fontColor($r('app.color.font'))
          TextInput({ placeholder: '请输入姓名', text: this.name })
            .fontSize(14)
            .placeholderFont({ size: 14 })
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.name = value
            })
        }
        .border({ width: { bottom: 1 }, color: $r('app.color.border') })

        Row() {
          Text('手机号')
            .width(50)
            .fontSize(14)
            .fontColor($r('app.color.font'))
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .fontSize(14)
            .type(InputType.PhoneNumber)
            .maxLength(12)
            .placeholderFont({ size: 14 })
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.phone = value
            })
            .onSubmit(() => {
              // TODO：提交
              this.onSubmit()
            })
        }
        .border({ width: { bottom: 1 }, color: $r('app.color.border') })
      }
      .padding({ left: 15, right: 15 })
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())
  }
}