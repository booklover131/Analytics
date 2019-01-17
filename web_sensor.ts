const get = require('lodash.get');
const assign = require('lodash.assign');
const cookie = require('js-cookie');

import { mixed as adaptor } from './adaptors';

/**
 * ShimoSensor
 */
export class ShimoSensor {
  // 同一页面间隔 8 小时再操作则再次发送 pv
  private pvIntervals = 8 * 3600 * 1000;
  private trackMaps: { [k: string]: any } = {};
  private pvStartTime = new Date();
  private editingGuid: string = '';

  /**
   * 构造函数
   *
   * @param [options] {object} 神策配置，默认 { server_url: `https://postdsc.shimo.im/sa` }
   * @param [options.shimo_url] {string} 石墨数据搜集接口
   */
  constructor(options?: any) {
    const isDebug = /[&?]trackDebug/.test(window.location.search);
    let project = 'default';

    let shimoUrl;
    if (window.location.host.match(/shimo.im/)) {
      project = 'production';
      shimoUrl = `https://dalog.shimo.im/logservice/web/coll.jpg?project=${project}`;
    }

    if (window.location.host.match(/shimodev.com/)) {
      shimoUrl = `https://shimodev.com/logservice/web/coll.jpg?project=${project}`;
    }

    this.pvIntervals = 8 * 3600 * 1000;
    this.trackMaps = {};

    if (this.disabled) {
      return;
    }

    adaptor.init({
      show_log: isDebug || false,
      server_url: `https://postdsc.shimo.im/sa?project=${project}`,
      shimo_url: shimoUrl || 'https://dont-send-data.com',
      ...options,
    });

    adaptor.clearAllRegister({});
    const deviceId = cookie.get('deviceId');
    adaptor.registerPage({
      userAgent: window.navigator.userAgent,
      shimo_device_id: deviceId,
    });

    const enterpriseId = get(window, 'cow.currentUser.teamId') || 0;
    const userId = get(window, 'cow.currentUser.id');
    const anonymous = !!(userId < 0);

    adaptor.setProfile({
      enterpriseId,
      anonymous,
    });

    const readonly = get(window, 'cow.readonly');

    if (readonly) {
      adaptor.registerPage({ readonly });
    }
  }

  private get disabled() {
    // 私有部署不需要埋点
    const isPrivateDeploy = get(window, 'process.env.PRIVATE_DEPLOY', false);
    return isPrivateDeploy;
  }

  /**
   * 设置用户信息
   *
   * @param options {object} 任意对象
   */
  public setProfile(options: { [k: string]: any }) {
    adaptor.setProfile(options);
  }

  /**
   * 注册页面信息
   *
   * @param options {object} 任意对象
   */
  public registerPage(options: { [k: string]: any }) {
    adaptor.registerPage(options);
  }

  /**
   * 标识用户 ID
   *
   * @param [userId] {number} 用户 ID
   */
  public login(userId?: number) {
    if (this.disabled) {
      return;
    }

    const shimoUserId = userId || get(window, 'cow.currentUser.id');

    adaptor.registerPage({ shimo_user_id: shimoUserId });

    if (shimoUserId > 0) {
      adaptor.login(shimoUserId);
    }
  }

  /**
   * 快捷方式
   * 等同于神策 quick 方法
   *
   * @param action {string} 事件
   */
  public quick(action: string) {
    if (this.disabled) {
      return;
    }
    adaptor.quick(action);
  }

  /**
   * 开始追踪
   *
   * @param [options] {object} 初始化值
   * @param [options.userId] {number} 初始化 userId，默认使用`window.cow.currentUser.id`
   * @param [options.xxx] {any} 其他的要一起追踪的值
   */
  public autoTrack(options: { [k: string]: any } = {}) {
    if (this.disabled) {
      return;
    }
    this.bindVisibilityChange();
    this.login(options.userId);
    this.registerPage(options);
    adaptor.quick('autoTrack');
    this.pvStartTime = new Date();
  }

  /**
   * 追踪单页面的 PV
   * 会监听 pushState/replaceState 等方法
   */
  public autoTrackSinglePage() {
    if (this.disabled) {
      return;
    }
    adaptor.quick('autoTrackSinglePage');
    this.pvStartTime = new Date();
  }

  /**
   * 追踪重复 PV
   * 超过 8 小时的认为是新的 PV
   */
  public trackRepeatedPV() {
    if (this.disabled) {
      return;
    }
    const actionTime = new Date();
    if (actionTime.getTime() - this.pvStartTime.getTime() >= this.pvIntervals) {
      adaptor.registerPage({ repeatedPV: true });
      this.autoTrackSinglePage();
    }
  }

  /**
   * 导入模块映射表
   *
   * @param newTrackMap {object} 映射表
   *
   * @example
   * ```js
   * sa.import({ tom: '监听按钮点击' })
   *
   * sa.track(1, 'tom')
   * // 等同于
   * sa.track(1, '监听按钮点击')
   * ```
   */
  public import(newTrackMap: { [key: string]: any }) {
    if (this.disabled) {
      return;
    }
    if (newTrackMap) {
      this.trackMaps = assign({}, this.trackMaps, newTrackMap);
    }
  }

  /**
   * 跟踪事件
   *
   * @param event {number|string} 事件名
   * @param params {object|string} 事件数据
   *
   * 此接口向下兼容原来的老写法 `track(productId, trackId, opsSuccessed, options)`
   *
   * @example
   * ```js
   * sa.track('eventName', { k1, k2 })
   *
   * // 老写法
   * sa.track(4, '按钮点击', true, { k1, k2 })
   * ```
   */
  public track(
    event: string | number,
    params: { [key: string]: any } | string,
    // 向下兼容
    opsSuccessed = true,
    options?: any
  ) {
    if (this.disabled) {
      return;
    }

    if (!event) {
      return;
    }

    if (
      typeof event === 'string' &&
      (typeof params === 'object' || typeof params === 'undefined')
    ) {
      adaptor.track(event, params || {});
      return;
    }

    // 传统用法
    const productId = event;
    const trackId = String(params);

    const eventType = getEventType(productId);
    const fileType = getFileType(productId);

    const opsName = this.trackMaps[trackId] || trackId;

    adaptor.track(eventType, {
      moduleName: fileType,
      opsName: this.trackMaps[opsName] || opsName,
      opsSuccessed,
      ...options,
    });
  }

  /**
   * 跟踪文档加载时间
   *
   * @param productId {number|string} 文档类型
   * @param loadTime {number} 加载时长
   * @param fileLoadSucessed {boolean} 是否成功
   */
  public loadingStatusTrack(
    productId: string,
    loadTime: any,
    fileLoadSucessed: boolean
  ) {
    if (this.disabled) {
      return;
    }
    const guid = get(window, 'cow.currentFile.guid');
    adaptor.track('loadingStatus', {
      moduleName: getFileType(productId),
      loadTime,
      fileID: guid,
      fileLoadSucessed,
    });
  }

  /**
   * 跟踪文档同步状态
   *
   * @param productId {number|string} 文档类型
   * @param type {string} 结果类型
   * @param saveSucessed {boolean} 是否成功
   */
  public syncStatusTrack(
    productId: number | string,
    type: string,
    saveSucessed: boolean
  ) {
    if (this.disabled) {
      return;
    }
    const guid = get(window, 'cow.currentFile.guid');
    adaptor.track('syncStatus', {
      fileType: getFileType(productId),
      type,
      status: saveSucessed,
      fileID: guid,
    });
  }

  /**
   * 追踪导出事件
   *
   * @param productId {number|string} 文档类型
   * @param fileFormat {string} 文件类型
   * @param exportSucessed {boolean} 是否成功
   * @param [extras] {object} 其他信息
   */
  public exportTrack(
    productId: number | string,
    fileFormat: string,
    exportSucessed: boolean,
    extras: any
  ) {
    if (this.disabled) {
      return;
    }
    const guid = get(window, 'cow.currentFile.guid');
    const data = {
      ...extras,
      fileType: getFileType(productId),
      fileFormat,
      fileUrl: guid,
      exportSucessed,
    };
    adaptor.track('export', data);
  }

  /**
   * 跟踪导入事件
   *
   * @param productId {string|number} 文档类型
   * @param fileFormat {string} 文件类型
   * @param importSucceed {boolean} 是否成功
   * @param importTime {number} 耗费时间
   */
  public importTrack(
    productId: number | string,
    fileFormat: string,
    importSucceed: boolean,
    importTime: Date
  ) {
    if (this.disabled) {
      return;
    }
    const guid = get(window, 'cow.currentFile.guid');
    adaptor.track('import', {
      fileType: getFileType(productId),
      fileFormat,
      fileUrl: guid,
      importSucceed,
      importTime,
    });
  }

  /**
   * 跟踪复制粘贴
   *
   * @param productId {string|number} 文档类型
   * @param pasteTime {number} 耗费时间
   * @param pasteSuccessed {boolean} 是否成功
   */
  public copyPasteTrack(
    productId: number | string,
    pasteTime: Date,
    pasteSuccessed: boolean
  ) {
    if (this.disabled) {
      return;
    }
    adaptor.track('copyPaste', {
      fileType: getFileType(productId),
      pasteTime,
      pasteSuccessed,
    });
  }

  /**
   * 跟踪编辑器错误
   *
   * @param productId {string|number} 文档类型
   * @param errorType {string} 错误类型
   * @param [options] {object} 其他信息
   */
  public editErrorTrack(
    productId: number | string,
    errorType: string,
    options: any
  ) {
    if (this.disabled) {
      return;
    }
    let params = {
      fileType: getFileType(productId),
      errorType,
    };
    if (typeof options === 'object') {
      params = assign({}, params, options);
    }
    adaptor.track('editError', params);
  }

  /**
   * 跟踪其他事件
   *
   * @param productId {string|number} 文档类型
   * @param eventType {string} 事件类型
   * @param errorType {string} 错误类型
   * @param [options] {object} 其他信息
   */
  public trackOther(
    productId: number | string,
    eventType: string,
    errorType: string,
    options: any
  ) {
    if (this.disabled) {
      return;
    }
    let params = {
      fileType: getFileType(productId),
      errorType,
    };
    if (typeof options === 'object') {
      params = assign({}, params, options);
    }
    adaptor.track(eventType, params);
  }

  /**
   * 跟踪编辑事件
   *
   * @param productId {string|number} 文档类型
   */
  public editTrack(productId: number | string) {
    if (this.disabled) {
      return;
    }
    const guid = get(window, 'cow.currentFile.guid');
    if (this.editingGuid !== guid) {
      this.editingGuid = guid;
      adaptor.track('edit', {
        fileType: getFileType(productId),
        fileID: guid,
      });
    }
  }

  /**
   * 跟踪 PV
   *
   * @param [options] {object} 初始化值
   * @param [options.userId] {number} 初始化 userId，默认使用`window.cow.currentUser.id`
   * @param [options.xxx] {any} 其他的要一起追踪的值
   */
  public appTrack(options: { [k: string]: any } = {}) {
    if (this.disabled) {
      return;
    }

    this.login(options.userId);
    this.registerPage(options);

    const file =
      get(window, 'cow.currentFile') || get(window, 'cow.tempCurrentFile');
    const trackData: { [k: string]: any } = {
      fileType: getFileType(file && file.type),
    };

    const readonly = get(window, 'cow.readonly');
    if (readonly) {
      trackData.readonly = readonly;
    }
    adaptor.track('appView', trackData);
  }

  private bindVisibilityChange() {
    let state: string;
    let visibilityChange: string = 'notExits';
    if (typeof document.hidden !== 'undefined') {
      visibilityChange = 'visibilitychange';
      state = 'visibilityState';
    } else if (typeof (document as any).mozHidden !== 'undefined') {
      visibilityChange = 'mozvisibilitychange';
      state = 'mozVisibilityState';
    } else if (typeof (document as any).msHidden !== 'undefined') {
      visibilityChange = 'msvisibilitychange';
      state = 'msVisibilityState';
    } else if (typeof (document as any).webkitHidden !== 'undefined') {
      visibilityChange = 'webkitvisibilitychange';
      state = 'webkitVisibilityState';
    }

    document.addEventListener(
      visibilityChange,
      () => {
        if ((document as any)[state] !== 'hidden') {
          this.trackRepeatedPV();
        }
      },
      false
    );
  }
}

function getFileType(id: string | number) {
  let fileType;
  /**
   * 如果传入的是 productId 则是 grafana 埋点的规则，是正数
   * 如果传入的是 file.type 则是 cow 里的文件类型字符串
   */
  switch (id) {
    case 2:
    case 'sheet':
      fileType = '新表格';
      break;
    case 3:
    case 'spreadsheet':
      fileType = '老表格';
      break;
    case 4:
    case 'newdoc':
      fileType = '新文档';
      break;
    case 5:
    case 'document':
      fileType = '老文档';
      break;
    case 'mosheet':
      fileType = '墨表格';
      break;
    default:
      return id;
  }
  return fileType;
}

function getEventType(productId: number | string) {
  let eventType;
  switch (productId) {
    case 2:
      eventType = 'newSheetOps';
      break;
    case 3:
      eventType = 'oldSheetOps';
      break;
    case 4:
      eventType = 'newDocOps';
      break;
    case 5:
      eventType = 'oldDocOps';
      break;
    default:
      return productId;
  }
  return eventType;
}

