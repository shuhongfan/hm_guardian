import { webSocket } from '@kit.NetworkKit'
import { promptAction } from '@kit.ArkUI'

/**
 * 使用WebSocket建立服务器与客户端的双向连接，
 * 需要先通过createWebSocket()方法创建WebSocket对象，
 * 然后通过connect()方法连接到服务器。
 * 当连接成功后，客户端会收到open事件的回调，之后客户端就可以通过send()方法与服务器进行通信。
 * 当服务器发信息给客户端时，客户端会收到message事件的回调。
 * 当客户端不要此连接时，可以通过调用close()方法主动断开连接，之后客户端会收到close事件的回调。
 若在上述任一过程中发生错误，客户端会收到error事件的回调。
 */
@Entry
@Component
struct WebSocketTestPage {
  // 消息列表
  @State list: string[] = []
  ws?: webSocket.WebSocket

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('建立WebSocket双向连接-接收')
            .onClick(() => {
              // 1. 创建 WebSocket 对象
              const ws = webSocket.createWebSocket()
              // 2. 通过 connect() 方法连接到服务器
              ws.connect('wss://guardian-api.itheima.net/verifyCode')
              // 3. 当连接成功后，客户端会收到 .on('open') 事件的回调
              ws.on('open', (err, data) => {
                if (err) { return }
                promptAction.showToast({ message: '连接成功' })
              })
              // 4. 当服务器发信息给客户端时，客户端会收到 .on('message') 事件的回调。
              ws.on('message', (err, data) => {
                if (err) { return } // 如果有错误直接退出
                // promptAction.showToast({ message: '收到服务器推送的消息：' + JSON.stringify(data, null, 2) })
                this.list.push(JSON.stringify(data, null, 2))
              })
              // 保存成全局 ws
              this.ws = ws
            })
          Button('断开 WebSocket 连接')
            .onClick(async () => {
              // 断开 WebSocket 双向连接
              await this.ws?.close()
              promptAction.showToast({ message: 'WebSocket 断开连接成功' })
            })
          Text(JSON.stringify(this.list, null, 2))
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}