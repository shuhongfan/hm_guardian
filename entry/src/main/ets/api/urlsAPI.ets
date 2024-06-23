/** token续期-请求参数 */
import { axiosInstance, AxiosResponseData } from '../common/utils/http';

/* 校验url是否合法-请求参数 */
export interface getUrlsCheckParams {
  /** url连接 */
  url: string;
}

/** url校验 */
export interface getUrlsCheckResponse {
  /** url是否合法 */
  isLegal: boolean;
}

/* 校验url是否合法 */
export function getUrlsCheckAPI(params: getUrlsCheckParams) {
  return axiosInstance.get
  <null, AxiosResponseData<getUrlsCheckResponse>, getUrlsCheckParams>
  ('/urls/check', { params })
}
