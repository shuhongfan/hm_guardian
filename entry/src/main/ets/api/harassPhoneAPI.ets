import { axiosInstance, AxiosResponseData } from '../common/utils/http';

/** 骚扰电话黑名单总数统计模型 */
export interface getHarassPhoneCountResponse {
  /** 骚扰电话黑名单总数 */
  total: number;
}

/* 骚扰电话数量查询 */
export function getHarassPhoneCountAPI() {
  return axiosInstance.get
  <null, AxiosResponseData<getHarassPhoneCountResponse>, null>
  ('/harass-phone/count')
}


/* 滚动加载骚扰电话列表-请求参数 */
export interface getHarassPhonePageParams {
  /** 上一页最后一个手机号码 */
  lastPhone: string;
}

/** 骚扰电话列表模型 */
export interface getHarassPhonePageResponse {
  /** 电话号码列表 */
  phones: string[];
}


/* 滚动加载骚扰电话列表 */
export function getHarassPhonePageAPI(params: getHarassPhonePageParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getHarassPhonePageResponse>, getHarassPhonePageParams>
  ('/harass-phone/page', { params })
}

