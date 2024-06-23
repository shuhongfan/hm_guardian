import { axiosInstance, AxiosResponseData } from '../common/utils/http';

/* 查询手机号标记和归属地信息-请求参数 */
interface getPhoneMarkParams {
  phone: string
}

/** 手机号标记信息 */
export interface getPhoneMarkResponse {
  /** 是否已经被标记 */
  isMarked: boolean;

  /** 归属地 */
  belongingAddress: string;

  /** 运营商类型，1：移动，2：联通，3：电信 */
  operatorType: PhoneMarkOperatorType;

  /** 标记次数 */
  total: number;

  /** 手机号标记类型,0：疑似诈骗，1：骚扰电话，2：广告推销，3：客服电话，4：快递送餐，5：保险理财，6，房产中介，7：企业电话，8：出租车，9：响一声 */
  type: PhoneMarkType;
}

/** 运营商类型 */
export enum PhoneMarkOperatorType {
  Unknown = 0, // 未知
  ChinaMobile = 1, // 移动
  ChinaUnicom = 2, // 联通
  ChinaTelecom = 3 // 电信
}

/** 手机号标记类型 */
export enum PhoneMarkType {
  /** 未标记 */
  None = -1,
  /** 骚扰电话 */
  Harassment = 0,
  /** 快递送餐 */
  Delivery = 1,
  /** 广告推销 */
  Telemarketing = 2,
  /** 房产中介 */
  RealEstateAgency = 3,
  /** 疑似诈骗 */
  SuspectedFraud = 4,
  /** 保险理财 */
  InsuranceAndFinance = 5,
  /** 出租车 */
  Taxi = 6,
  /** 招聘猎头 */
  JobHunting = 7,
}

/* 查询手机号标记和归属地信息 */
export function getPhoneMarkAPI(params: getPhoneMarkParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getPhoneMarkResponse>, getPhoneMarkParams>
  ('/phone/mark', { params })
}

/** 手机号标记模型 */
export interface postPhoneMarkData {
  /** 是否加入黑名单 */
  joinBlackList?: boolean;

  /** 手机号或电话号 */
  phone: string;

  /** 标记类型，0：疑似诈骗，1：骚扰电话，2：广告推销，3：客服电话，4：快递送餐，5：保险理财，6，房产中介，7：企业电话，8：出租车，9：响一声 */
  type: number;
}

/* 标记手机号 */
export function postPhoneMarkAPI(data: postPhoneMarkData) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, postPhoneMarkData>
  ('/phone/mark', data)
}

/** 滚动分页查询手机标记-请求参数 */
export interface getPhoneMarkPageParams {
  /** 上一标记的id, 第一次查询传 '' */
  lastId: string;
}


/** 手机标记模型 */
export interface getPhoneMarkPageItem {
  /** 标记id */
  id?: string;

  /** 手机号 */
  phone?: string;

  /** 标记类型,0：疑似诈骗，1：骚扰电话，2：广告推销，3：客服电话，4：快递送餐，5：保险理财，6，房产中介，7：企业电话，8：出租车，9：响一声 */
  type?: string;
}


/** 滚动分页查询手机标记 */
export function getPhoneMarkPageAPI(params: getPhoneMarkPageParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getPhoneMarkPageItem[]>, getPhoneMarkPageParams>
  ('/phone/mark/page', { params })
}


/* 手机号黑名单添加接口-请求参数 */
interface postPhoneBlackListData {
  /** 黑名单手机号 */
  phone: string
}

/** 手机号黑名单添加接口 */
export function postPhoneBlackListAPI(data: postPhoneBlackListData) {
  return axiosInstance.post
  <null, AxiosResponseData<null>, postPhoneBlackListData>
  ('/phone/black-list', data)
}

/** 手机黑名单删除模型 */
export interface deletePhoneBlackListData {
  /** 黑名单手机号 */
  phone: string;
}

/** 从黑名单中删除 */
export function deletePhoneBlackListAPI(data: deletePhoneBlackListData) {
  return axiosInstance.delete
  <null, AxiosResponseData<null>, deletePhoneBlackListData>
  ('/phone/black-list', { data: data })
}

/** 滚动分页查询手机号黑名单-请求参数 */
export interface getPhoneBlackListPageParams {
  /** 上一页最后一条手机号 */
  lastPhone: string;
}

/** 手机号黑名单查询响应模型 */
export interface getPhoneBlackListPageResponse {
  /** 手机号黑名单列表 */
  phones: string[];

  /** 手机号黑名单总数 */
  total: number;
}


/** 滚动分页查询手机号黑名单 */
export function getPhoneBlackListPageAPI(params: getPhoneBlackListPageParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getPhoneBlackListPageResponse>, getPhoneBlackListPageParams>
  ('/phone/black-list/page', { params })
}

