import { relationalStore, ValuesBucket } from '@kit.ArkData'

// 隐私笔记的类型
// ValuesBucket 数据库类型约束
export interface PrivacyNoteDBInfo extends ValuesBucket {
  id: number | null // 新增时 id 设置为 null ，可实现 id 自增
  title: string
  content: string
  date_added: number
}

// 隐私笔记数据库封装
class PrivacyNoteDB {
  // 操作数据库的实例(数据库文件)
  private store: relationalStore.RdbStore | null = null
  // 数据库表名
  private tableName = 'privacy_note'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date_added INTEGER NOT NULL
      )`

  // 获取数据库操作的实例(创建/打开数据库文件)
  async getStoreInstance() {
    // 创建/打开数据库文件
    const store = await relationalStore.getRdbStore(getContext(), {
      name: 'guardian.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1 // 安全等级(跨设备共享等级)
    })
    // return 操作数据库的实例
    return store
  }

  // 类的构造器，new 的时候会自动触发
  constructor() {
    // 创建/打开数据库文件
    this.getStoreInstance()
      .then(store => {
        // 执行 sql 语句，用于创建数据库的表
        store.executeSql(this.sqlCreate)
      })
  }

  // 新增数据
  async insert(value: PrivacyNoteDBInfo) {
    // 创建/打开数据库文件
    const store = await this.getStoreInstance()
    // 新增数据(表名, 数据)
    return store.insert(this.tableName, value)
  }
}

// 通过小写 p 开头的类实例操作数据库，创建数据库，建表，增、删、查、改
export const privacyNoteDB = new PrivacyNoteDB()