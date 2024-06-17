import { relationalStore } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'

/*
可通过 AI 辅助，基于 ArkTS 的 interface 生成对应的建表语句：
https://www.doubao.com/thread/w8da29a1c6f1a547d

*
* 我的提示语：
*
基于以下类型，帮我准备一个 SQLite 建表语句：
要求：
  1. id 为主键
  2. 其他字段不允许空
  3. 如果表不存在才创建

// 隐私笔记
export interface PrivacyNoteDBInfo {
  id: number | null  // 新增时设置 id 为空值 null，用于自增 id
  title: string      // 标题
  content: string    // 内容
  date_added: number // 添加日期
}

*
* AI生成的 SQLite 语句
*
CREATE TABLE IF NOT EXISTS privacy_note (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    date_added INTEGER NOT NULL
);
 */

@Entry
@Component
struct DatabaseTestPage {

  store: relationalStore.RdbStore | null = null
  sql: string = `CREATE TABLE IF NOT EXISTS privacy_note (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    date_added INTEGER NOT NULL
);`

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('创建(打开)数据库文件')
            .onClick(async () => {
              // 创建数据库文件  getRdbStore
              this.store = await relationalStore.getRdbStore(getContext(), {
                name: 'heima2.db', // 数据库文件名
                securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全等级(跨端共享)
              })
              promptAction.showToast({ message: '数据库文件创建成功' })
            })

          Button('创建表')
            .onClick(async () => {
              // 创建表
              await this.store?.executeSql(this.sql)
              promptAction.showToast({ message: '建表成功' })
            })

          Button('查询表信息')
            .onClick(async () => {
              // 查表，谓词传入表名
              const predicates = new relationalStore.RdbPredicates('privacy_note')
              const resultSet = await this.store?.query(predicates)
              promptAction.showToast({ message: '表字段名称' + resultSet?.columnNames })
            })

          Button('删除数据库文件')
            .enabled(false)
            .onClick(async () => {
              // 删除数据库文件 deleteRdbStore
              await relationalStore.deleteRdbStore(getContext(), 'heima2.db')
              promptAction.showToast({ message: '数据库文件删除成功' })
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('关系型数据库')
    .titleMode(NavigationTitleMode.Mini)
  }
}