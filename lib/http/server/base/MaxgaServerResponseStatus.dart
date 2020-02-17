enum MaxgaServerResponseStatus {
  SUCCESS,
  TIMEOUT,
  PARAM_ERROR,
  SHOULD_LOGIN,
  AUTH_PASSWORD_ERROR,
  USER_NOT_EXIST,
  USERNAME_EXISTED,
  JWT_TIMEOUT,
  UPDATE_VALUE_EXIST,
  UPDATE_VALUE_OUT_OF_DATE,
  OPERATION_NOT_PERMIT,
  SERVICE_FAILED
}

const Map<MaxgaServerResponseStatus, String> MaxgaServerResponseCodeMessageMap = {
  MaxgaServerResponseStatus.PARAM_ERROR: "参数错误",
  MaxgaServerResponseStatus.SHOULD_LOGIN: "需要登录",
  MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR: "登录验证失败",
  MaxgaServerResponseStatus.USERNAME_EXISTED: "用户不存在",
  MaxgaServerResponseStatus.JWT_TIMEOUT: "用户名已经存在",
  MaxgaServerResponseStatus.OPERATION_NOT_PERMIT: "需要登录",
  MaxgaServerResponseStatus.SERVICE_FAILED: "用户名已经存在",
};
