import PXL from './abi-class/PXL.js'
import AccountManager from './abi-class/AccountManager.js'
import IContent from './abi-class/IContent.js'
import ContentsManager from './abi-class/ContentsManager.js'
import Fund from './abi-class/Fund.js'
import FundManager from './abi-class/FundManager.js'
import SupporterPool from './abi-class/SupporterPool.js'
import Report from './abi-class/Report.js'
import DepositPool from './abi-class/DepositPool.js'
import UserPaybackPool from './abi-class/UserPaybackPool.js'
import Council from './abi-class/Council.js'

const PictionNetworkPlugin = {
  install(Vue, pictionConfig) {
    Vue.prototype.pictionConfig = pictionConfig;

    Vue.prototype.$contract = {};

    Vue.prototype.$contract.pxl = new PXL(
      pictionConfig.pictionAddress.pxl,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.accountManager = new AccountManager(
      pictionConfig.managerAddress.accountManager,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.contentInterface = new IContent(
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.contentsManager = new ContentsManager(
      pictionConfig.managerAddress.contentsManager,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.fund = new Fund(
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.fundManager = new FundManager(
      pictionConfig.managerAddress.fundManager,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.supporterPool = new SupporterPool(
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.report = new Report(
      pictionConfig.pictionAddress.report,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.depositPool = new DepositPool(
      pictionConfig.pictionAddress.depositPool,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.userPaybackPool = new UserPaybackPool(
      pictionConfig.pictionAddress.userPaybackPool,
      pictionConfig.account,
      pictionConfig.defaultGas
    )

    Vue.prototype.$contract.council = new Council(
      pictionConfig.pictionAddress.council,
      pictionConfig.account,
      pictionConfig.defaultGas
    )
  }
}

export default PictionNetworkPlugin;
