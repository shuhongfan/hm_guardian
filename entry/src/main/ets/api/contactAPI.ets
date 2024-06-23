import { contact } from '@kit.ContactsKit';
import { axiosInstance, AxiosResponseData } from '../common/utils/http';

/** 通讯录保存模型 */
export interface postPhoneBookData {
  /** 通讯录 */
  contacts: contact.Contact[];

  /** 设备型号 */
  phoneType?: string;
}

/** 备份通讯录 */
export function postPhoneBookAPI(data: postPhoneBookData) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, postPhoneBookData>
  ('/phone/book', data)
}


/** 滚动分页查询手机号黑名单-请求参数 */
export interface getPhoneBookHistoryParams {
  /** 上次查询备份id */
  lastId: string;
}


/** 备份记录 */
export interface getPhoneBookHistoryItem {
  /** 备份时间 */
  createTime: string;

  /** 通讯录备份id */
  id: string;

  /** 手机类型 */
  phoneType: string;

  /** 联系人数量 */
  contactsNum: number;
}


/** 滚动分页查询手机号黑名单 */
export function getPhoneBookHistoryAPI(params: getPhoneBookHistoryParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getPhoneBookHistoryItem[]>, getPhoneBookHistoryParams>
  ('/phone/book/history', { params })
}

/** 查询手机通讯录备份 */
export interface getPhoneBookByIdResponse {
  /** 通讯录 */
  contacts: contact.Contact[];

  /** 通讯录联系人数 */
  contactsNum: number;

  /** 备份时间 */
  createTime: string;
}

/** 查询手机通讯录备份 */
export function getPhoneBookByIdAPI(id: string) {
  return axiosInstance.get
  <null, AxiosResponseData<getPhoneBookByIdResponse>, null>
  (`/phone/book/${id}`)
}

/** 删除通讯录备份 */
export function deletePhoneBookByIdAPI(id: string) {
  return axiosInstance.delete
  <null, AxiosResponseData<null>, null>
  (`/phone/book/${id}`)
}
