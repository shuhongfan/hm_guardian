import { relationalStore, ValuesBucket } from '@kit.ArkData'
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

// ValuesBucket 数据库值的类型
interface privacyNote extends ValuesBucket {
  id: number | null
  title: string
  content: string
  date_added: number
}

@Entry
@Component
struct DatabaseTestPage {
  // 数据库文件是否 创建/打开
  @State isDBOpen: boolean = false
  // 数据库对象
  store: relationalStore.RdbStore | null = null
  tableName: string = 'privacy_note'
  sql: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    date_added INTEGER NOT NULL
);`

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('创建(打开)数据库文件 - getRdbStore')
            .onClick(async () => {
              // 创建数据库文件(已存在文件则为打开)  getRdbStore
              this.store = await relationalStore.getRdbStore(getContext(), {
                name: 'heima2.db', // 数据库文件名
                securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全等级(跨端共享)
              })
              // 数据库文件是否 创建/打开
              this.isDBOpen = true
              promptAction.showToast({ message: '数据库文件创建/打开成功' })
            })

          Button('创建表 - executeSql')
            .enabled(this.isDBOpen)
            .onClick(async () => {
              // 创建表
              await this.store?.executeSql(this.sql)
              promptAction.showToast({ message: '建表成功' })
            })

          Button('查询表信息 - query')
            .enabled(this.isDBOpen)
            .onClick(async () => {
              // 查表，谓词传入表名
              //   this.store      数据库(文件)操作对象
              //   privacy_note    表名
              const predicates = new relationalStore.RdbPredicates(this.tableName)
              const resultSet = await this.store?.query(predicates)
              promptAction.showToast({ message: '表字段名称' + resultSet?.columnNames })
            })

          Button('新增数据 - insert')
            .enabled(this.isDBOpen)
            .onClick(async () => {
              // insert 新增数据，返回值为新增数据的 id
              // 注意事项：insert 新增的时候，对象的 key: value 都要符合建表时的 字段和类型
              const id = await this.store?.insert(this.tableName, {
                id: null,
                title: '测试的标题',
                content: '测试的内容',
                date_added: Date.now()
              } as privacyNote)
              promptAction.showToast({ message: '新增数据成功，id为：' + id })
              // 如何通过 SQLiteStudio 打开数据库文件
              //   1. 通过 DevEco Studio 导出 /data/app/el2/100/database/{包名}/entry/rdb 路径下的数据库文件夹
              //   2. 通过 SQLiteStudio 添加数据库 heima.db 文件关联
              //   3. 在 SQLiteStudio 软件左侧
              //       1. 双击数据库文件(heima.db)
              //       2. 双击表(privacy_note)
              //       3. 点击数据->网格视图  即可查看数据
            })

          Button('查询数据 - query')
            .enabled(this.isDBOpen)
            .onClick(async () => {
              // predicates  谓词(查询条件)
              const predicates = new relationalStore.RdbPredicates(this.tableName)
              // predicates
              //     .orderByAsc('字段名')  // 正序：按字段从小到大   如：微信聊天消息
              //     .orderByDesc('字段名') // 倒序：按字段从大到小   如：微信朋友圈

              //     .in('字段名', 数组)      // 查找多条   相当于:  includes()
              //     .equalTo('字段名', 值)   // 查找单条   相当于:  ===

              //     .offsetAs(3)          // 偏移
              //     .and()                // &&
              //     .limitAs(3)           // 提取数量

              predicates.orderByDesc('id') // 根据 id 倒序排列

              // predicates.in('id', [3, 2, 5])
              // predicates.equalTo('id', 3)
              // resultSet   结果集(数据)
              const resultSet = await this.store?.query(predicates)
              // 需求1. 查询总数量(行数)
              // resultSet.rowCount 数据总数量(行数)
              const rowCount = resultSet?.rowCount
              // 踩坑：resultSet?.rowCount 可能会出现 -1，小于 0 时人为修正为 0
              // const rowCount = resultSet?.rowCount as number < 0 ? 0 : resultSet?.rowCount
              // AlertDialog.show({ message: '数据总条数：' + rowCount })
              // 需求2: 查询列表
              const list: privacyNote[] = []
              // resultSet?.goToNextRow() 移动指针到下一行，如果有数据返回 true
              while (resultSet?.goToNextRow()) {
                // 循环时：按列索引提取数据
                const item: privacyNote = {
                  // getLong(列索引)      提取整数
                  // getString(列索引)    提取字符串
                  id: resultSet.getLong(0),
                  title: resultSet.getString(1),
                  content: resultSet.getString(2),
                  date_added: resultSet.getLong(3),
                }
                // 循环时：追加到数组中
                list.push(item)
              }
              // 注意：循环结束后，在 while 结构体外，就能获取到所有数据
              AlertDialog.show({ message: '数据列表：' + JSON.stringify(list, null, 2) })
            })

          Button('删除数据 - delete')
            .enabled(this.isDBOpen)
            .onClick(async () => {
              // 谓词：查询条件
              const predicates = new relationalStore.RdbPredicates(this.tableName)
              // 限定条件
              predicates.in('id', [15, 16]) // in 查找多项
              // predicates.equalTo('id', 20) // equalTo 查找一项
              // 注意：删除数据时，记得配合 predicates 添加限定条件，否则会删除所有数据
              await this.store?.delete(predicates)
              promptAction.showToast({ message: '数据删除成功' })
            })

          Button('更新数据 - update')
            .onClick(async () => {
              // 谓词：查询条件
              const predicates = new relationalStore.RdbPredicates(this.tableName)
              predicates.equalTo('id', 21) // 根据 id 查找一项
              // 注意：更新数据时，记得配合 predicates 添加限定条件，否则会修改所有数据
              await this.store?.update({
                title: '修改后的标题',
                content: '写代码能饱'
              } as privacyNote, predicates)
              promptAction.showToast({ message: '数据更新成功' })
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