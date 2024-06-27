import {
  BizType,
  postCodeGraphicCheckAPI,
  postCodeSmsSendAPI,
  postUserLoginPasswdAPI,
  postUserLoginVerifyCodeAPI
} from '../../api'
import { BASE_URL, LOGIN_INFO, LoginInfoResponse } from '../../common/constants'
import { promptAction, router } from '@kit.ArkUI'


@Entry
@Component
struct UserLoginPage {
  // 用户信息持久化
  @StorageLink(LOGIN_INFO) loginInfo: LoginInfoResponse = {}
  // 手机号 (练习时换成自己的手机号，补充够12位)
  @State phoneNumber: string = '135353330333'
  // 短信验证码
  @State verifyCode: string = ''
  // 显示半模态转场结构
  @State isShowSheet: boolean = false
  // 用于更新验证码的时间戳
  @State timestamp: number = Date.now()
  // 图形验证码
  @State graphicCode: string = ''
  // 倒计时数值
  @State count: number = 0
  // 倒计时定时器
  private intervalID: number = -1

  // 提交图形验证码
  async onGraphicCodeSubmit() {
    try {
      // 1. 后端校验图形验证码
      await postCodeGraphicCheckAPI({
        bizType: BizType.PhoneLogin,
        phone: this.phoneNumber,
        verifyCode: this.graphicCode
      })
      // 2. 关闭半模态弹窗
      this.isShowSheet = false
      // 3. 清空输入框，方便下次输入
      this.graphicCode = ''
      // 4. 刷新图形验证码
      this.timestamp = Date.now()
      // 5. 发送短信验证码
      this.onSendSmsCode()
    } catch (error) {
      // 刷新图形验证码
      this.timestamp = Date.now()
    }
  }

  // 发送短信验证码
  async onSendSmsCode() {
    // 1. 调用接口让后端发送短信到手机上
    await postCodeSmsSendAPI({
      bizType: BizType.PhoneLogin,
      phone: this.phoneNumber
    })
    // 2. 更新界面倒计时
    this.startCountDown()
    // 3. 用户轻提示
    promptAction.showToast({ message: `短信已发送到${this.phoneNumber}上，请注意查收` })
  }

  // 界面倒计时
  startCountDown() {
    // 初始化倒计时的秒数
    this.count = 120
    // 清理旧的定时器，并启动新的定时器
    clearInterval(this.intervalID)
    this.intervalID = setInterval(() => {
      // 每隔一秒自减 1
      this.count--
      // 如果数值小于 0，清理定时器
      if (this.count <= 0) {
        clearInterval(this.intervalID)
      }
    }, 1000)
  }

  // 页面销毁
  aboutToDisappear() {
    // 清理定时器
    clearInterval(this.intervalID)
  }

  // 用户登录表单提交
  async onLoginSubmit() {
    // 1. 手机号+短信验证码登录
    const res = await postUserLoginVerifyCodeAPI({
      phone: this.phoneNumber,
      verifyCode: this.verifyCode,
    })
    // 2. 持久化存储
    this.loginInfo = res.data.result
    // 3. 返回上一页
    router.back()
    // 轻提示
    promptAction.showToast({ message: '登录成功' })
  }

  // 半模态转场
  @Builder
  SheetBuilder() {
    Column() {
      Text('图形验证码')
        .fontSize(16)
        .fontColor($r('app.color.font'))
        .margin({ top: 20, bottom: 50 })

      Column({ space: 20 }) {
        Row({ space: 10 }) {
          TextInput({ placeholder: '图形验证码', text: this.graphicCode })
            .fontSize(14)
            .height(42)
            .layoutWeight(1)
            .maxLength(4)
            .onChange((value) => {
              this.graphicCode = value
            })
            .onSubmit(() => {
              // TODO:提交图形验证码
              this.onGraphicCodeSubmit()
            })
          // 图形验证码图片
          Image(`${BASE_URL}/code/graphic?phone=${this.phoneNumber}&bizType=${1}&timestamp=${this.timestamp}`)
            .width(108)
            .height(42)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              // 更新图片路径中的 State，让 Image 组件刷新，Image 组件刷新时就会自动往服务器发送新的图片请求，从而实现刷新图形验证码
              this.timestamp = Date.now()
            })
        }

        Button("提交")
          .height(42)
          .backgroundColor($r('app.color.brand'))
          .width('100%')
          .enabled(this.graphicCode.length > 0)
          .onClick(() => {
            // TODO:提交图形验证码
            this.onGraphicCodeSubmit()
          })
      }
    }
    .padding({ left: 30, right: 30 })
    .width('100%')
    .height('100%')
  }

  build() {
    Navigation() {
      Column() {
        Row({ space: 30 }) {
          Text('验证码登录')
            .fontSize(22)
            .fontWeight(500)
            .fontColor($r('app.color.font'))
        }
        .width('100%')

        Column({ space: 10 }) {
          TextInput({ placeholder: '请输入手机号', text: this.phoneNumber })
            .type(InputType.PhoneNumber)
            .maxLength(12)
            .fontSize(14)
            .height(50)
            .backgroundColor(Color.Transparent)
            .border({ width: { bottom: 1 }, color: $r('app.color.border'), radius: 0 })
            .padding(0)
            .onChange((value) => {
              this.phoneNumber = value
            })

          Stack({ alignContent: Alignment.End }) {
            TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
              .type(InputType.Number)
              .maxLength(6)
              .fontSize(14)
              .height(50)
              .backgroundColor(Color.Transparent)
              .border({ width: { bottom: 1 }, color: $r('app.color.border'), radius: 0 })
              .padding(0)
              .onChange((value) => {
                this.verifyCode = value
              })
              .onSubmit(() => {
                this.onLoginSubmit()
              })
            if (this.count > 0) {
              Text(this.count + '秒后重发')
                .fontSize(14)
                .fontColor($r('app.color.font_sub'))
            } else {
              Text('获取验证码')
                .fontSize(14)
                .fontColor($r('app.color.brand'))
                .enabled(this.phoneNumber.length > 0)
                .onClick(() => {
                  this.isShowSheet = true
                })
            }
          }
        }
        .margin({ top: 40, bottom: 40 })

        Column({ space: 20 }) {
          Button('登录')
            .backgroundColor($r('app.color.brand'))
            .height(42)
            .width('100%')
            .enabled(this.phoneNumber.length > 0 && this.verifyCode.length > 0)
            .onClick(() => {
              // TODO:登录表单提交
              this.onLoginSubmit()
            })

          Button('帐号密码快速登录-测试用')
            .backgroundColor($r('app.color.brand'))
            .height(42)
            .width('100%')
            .onClick(async () => {
              const res = await postUserLoginPasswdAPI({
                phone: '120666666673',
                passwd: '888itcast.CN764%...'
              })
              // 2. 持久化存储
              this.loginInfo = res.data.result
              // 3. 返回上一页
              router.back()
            })

          Text('仅用于IT培训教学使用，为保障您的个人信息安全请勿向平台录入任何个人敏感信息（如手机号、身份证号等）！')
            .fontSize(14)
            .width('100%')
            .fontColor($r('app.color.danger'))
            .margin({ top: 50 })
        }
      }
      .padding({ left: 30, right: 30, top: 30 })
      .width('100%')
      .height('100%')
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .bindSheet($$this.isShowSheet, this.SheetBuilder(), {
      // 半模态转场,屏幕高度一半，无法修改关闭图标样式
      detents: [SheetSize.MEDIUM],
      backgroundColor: $r('app.color.white')
    })
  }
}

