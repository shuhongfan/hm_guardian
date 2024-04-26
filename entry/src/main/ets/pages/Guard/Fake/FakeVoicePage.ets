import { showDevelopingTips } from '../../../common/dev'

interface Item {
  text: string
  src: string
  time: number
}

@Entry
@Component
struct FakeVoiceIndexPage {
  @State playingSrc: string = ''
  @State isRecording: boolean = false
  @State list: Item[] = [
    { text: '把那个快递给我放门口吧，我一会再拿，谢谢啊', src: 'lab_voice_trick_1.m4a', time: 7 },
    { text: '好，你放门口吧，我等会儿来拿', src: 'lab_voice_trick_2.m4a', time: 4 },
    { text: '老婆，谁呀？', src: 'lab_voice_trick_3.m4a', time: 3 },
    { text: '谁啊！干嘛呢！再不走报警了啊！', src: 'lab_voice_trick_4.m4a', time: 9 },
    { text: '宝贝，我在老地方等你呢，你到哪了？', src: 'lab_voice_trick_5.m4a', time: 5 },
    { text: '你在原地等我一会，我马上就到', src: 'lab_voice_trick_6.m4a', time: 5 },
    { text: '还有多长时间呀？我来接你吧', src: 'lab_voice_trick_7.m4a', time: 4 },
  ]

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
      Stack() {
        Scroll() {
          Column() {
            // 标题
            this.TitleBuilder('安全守护语音包',
              '推荐场景：外卖/快递上门、打车、走夜路等关键时刻，您可以通过此语音包伪装自己，震慑对方，降低危险性。')
            // 列表
            Column({ space: 20 }) {
              ForEach(this.list, (item: Item) => {
                Column() {
                  Stack() {
                    Row({ space: 5 }) {
                      if (this.playingSrc === item.src) {
                        ImageAnimator()
                          .images([
                            { src: $r('app.media.ic_public_voice1') },
                            { src: $r('app.media.ic_public_voice2') },
                            { src: $r('app.media.ic_public_voice3') },
                          ])
                          .state(AnimationStatus.Running)
                          .duration(1000)
                          .iterations(item.time)
                          .reverse(true)
                          .height(18)
                          .width(18)
                          .onFinish(() => {
                            this.playingSrc = ''
                          })
                      } else {
                        Image($r("app.media.ic_public_voice"))
                          .height(18)
                          .width(18)
                      }
                      Text(item.time + ' 〃')
                        .fontColor('#fff')
                    }
                    .padding({ left: 5 })

                    // 绘制小三角
                    Polygon({ width: 5, height: 10 })
                      .points([[0, 5], [5, 0], [5, 10]])
                      .fill('#1bd389')
                      .margin({ left: -5 })
                  }
                  .alignContent(Alignment.Start)
                  .width(50 + item.time * 4)
                  .height(32)
                  .backgroundColor('#1bd389')
                  .borderRadius(3)
                  .margin({ left: 5 })
                  .onClick(() => {
                    // TODO: 点击播放声音 - 单次
                  })

                  Text(item.text)
                    .fontSize(12)
                    .fontColor($r('app.color.font'))
                    .margin({ top: 10 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              })
            }
            .padding({ left: 20, right: 20, bottom: 20 })

            Divider()
              .strokeWidth(10)
              .color('#f7f7f7')
            // TODO: 如果有自定义语音包，则显示以下内
            this.TitleBuilder('自定义语音包', '随心定制个性语音包（限定5条）')

            Column({ space: 15 }) {
              ForEach(Array.from({ length: 5 }), () => {
                Column() {
                  Row() {
                    Stack() {
                      Row() {
                        if (false) {
                          ImageAnimator()
                            .images([
                              { src: $r('app.media.ic_public_voice1') },
                              { src: $r('app.media.ic_public_voice2') },
                              { src: $r('app.media.ic_public_voice3') },
                            ])
                            .state(AnimationStatus.Running)
                            .duration(1000)
                            .iterations(10)
                            .reverse(true)
                            .height(18)
                            .width(18)
                            .onFinish(() => {
                              this.playingSrc = ''
                            })
                        } else {
                          Image($r("app.media.ic_public_voice"))
                            .height(18)
                            .width(18)
                        }
                        Text(' 7〃')
                          .fontColor('#fff')
                      }
                      .padding({ left: 8 })

                      // 绘制小三角
                      Polygon({ width: 5, height: 10 })
                        .points([[0, 5], [5, 0], [5, 10]])
                        .fill('#1bd389')
                        .margin({ left: -5 })
                    }
                    .alignContent(Alignment.Start)
                    .width(85)
                    .height(32)
                    .backgroundColor('#1bd389')
                    .borderRadius(3)
                    .margin({ left: 5 })

                    Row({ space: 15 }) {
                      Image($r('app.media.ic_public_edit'))
                        .width(20)
                        .aspectRatio(1)
                      Image($r('app.media.ic_public_chat'))
                        .width(20)
                        .aspectRatio(1)
                      Image($r('app.media.ic_public_delete'))
                        .width(20)
                        .aspectRatio(1)
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)

                  Text('自定义语音')
                    .fontSize(12)
                    .fontColor($r('app.color.font'))
                    .margin({ top: 10 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .border({ width: { bottom: 1 }, color: $r('app.color.border') })
                .padding({ bottom: 10 })
              })
            }
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .justifyContent(FlexAlign.Start)
        }
        .scrollable(ScrollDirection.Vertical)

        // 固定的底部 - 状态1
        Column() {
          if (this.isRecording === false) {
            // 默认状态
            Text('长按录制变声语音包')
              .fontSize(16)
              .fontColor($r('app.color.font'))
            Text('最长可录制30秒')
              .fontSize(12)
              .fontColor($r('app.color.font'))
              .margin({ top: 10, bottom: 20 })
            Image($r('app.media.ic_circle_recorder'))
              .height(70)
              .aspectRatio(1)
          } else {
            // 录制状态
            Row() {
              // TODO: 录制中的动画交互效果
              Divider()
                .strokeWidth(1)
            }
            .width('100%')
            .height(30)
            .padding({ left: 20, right: 20 })

            Text('00:01')
              .fontSize(14)
              .fontColor($r('app.color.font_sub'))
              .margin({ top: 10, bottom: 10 })

            Stack() {
              Image($r('app.media.ic_circle_recorder_active'))
                .height(70)
                .aspectRatio(1)
              // 进度条组件
              Progress({ value: 10, total: 100, type: ProgressType.Ring })
                .width(86)
                .backgroundColor(Color.Transparent)
            }
          }
        }
        .width('100%')
        .height(236)
        .padding({ top: 40 })
        .backgroundColor('#fff')
        .shadow({
          offsetX: 0,
          offsetY: 2,
          radius: 18,
          color: '#66E4E4E4'
        })
        .borderRadius({
          topLeft: 12,
          topRight: 12,
          bottomLeft: 0,
          bottomRight: 0
        })
        .visibility(Visibility.None)

        // 固定的底部 - 状态2
        Row() {
          Image($r('app.media.ic_circle_recorder'))
            .width(30)
          Text('录制变声语音包')
            .fontSize(16)
            .fontColor($r('app.color.font'))
            .margin({ left: 12 })
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#fff')
        .shadow({
          offsetX: 0,
          offsetY: 2,
          radius: 18,
          color: '#66E4E4E4'
        })
        .borderRadius({
          topLeft: 12,
          topRight: 12,
          bottomLeft: 0,
          bottomRight: 0
        })
        .visibility(Visibility.Visible) // 默认隐藏
        .onClick(() => {
          showDevelopingTips()
        })

        // 固定的底部 - 变声效果选择
        Stack({ alignContent: Alignment.TopEnd }) {
          Column() {
            Text('请选择变声效果')
              .fontSize(16)
              .fontColor($r('app.color.font'))
              .margin({ top: 20, bottom: 20 })
            Row({ space: 12 }) {
              ForEach(Array.from({ length: 4 }), () => {
                Column() {
                  Image('/common/images/FakeVoicePage_yuansheng.png')
                    .width(45)
                    .aspectRatio(1)
                  Text('原声')
                    .fontSize(12)
                    .fontColor(true ? '#fff' : '#0C273D')
                    .backgroundColor(true ? $r('app.color.brand') : Color.Transparent)
                    .height(20)
                    .margin({ top: 5 })
                    .borderRadius(20 / 2)
                    .padding({ left: 8, right: 8 })
                }
                .justifyContent(FlexAlign.Center)
                .layoutWeight(1)
                .height(82)
                .borderWidth(1)
                .borderRadius(10)
                .borderColor(true ? $r('app.color.brand') : $r('app.color.border'))
              })
            }
            .padding({ left: 20, right: 20 })

            Row({ space: 15 }) {
              Button('保存')
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .border({ width: 1, color: $r('app.color.border') })
                .borderRadius(10)
                .backgroundColor('#fff')
                .fontColor($r('app.color.font'))
              Button('分享')
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .borderRadius(10)
            }
            .padding({ left: 15, right: 15 })
            .layoutWeight(1)
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .height(236)
          .backgroundColor('#fff')
          .shadow({
            offsetX: 0,
            offsetY: 2,
            radius: 18,
            color: '#66E4E4E4'
          })
          .borderRadius({
            topLeft: 12,
            topRight: 12,
            bottomLeft: 0,
            bottomRight: 0
          })

          Image($r('app.media.ic_public_close'))
            .width(25)
            .margin({ right: 15, top: 15 })
        }
        .visibility(Visibility.None)
      }
      .alignContent(Alignment.Bottom)
    }
    .title('伪装声音')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}