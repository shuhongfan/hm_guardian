import { axiosInstance, AxiosResponseData } from '../common/utils/http'

export function getTestAPI() {
  return axiosInstance.get
  <null, AxiosResponseData<string>, null>
  ('/test')
}
