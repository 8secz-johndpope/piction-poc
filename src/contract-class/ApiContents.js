import {abi} from '@contract-build-source/ApiContents'
import Comic from '@models/Comic';
import Episode from '@models/Episode';
import Web3Utils from '@utils/Web3Utils'
import BigNumber from 'bignumber.js'

class ApiContents {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract() {
    return this._contract;
  }

  // 작품 목록 조회
  async getComics(accountManagerContract) {
    let result = await this._contract.methods.getComics().call();
    result = Web3Utils.prettyJSON(result);
    if (result.comicAddress.length == 0) {
      return [];
    } else {
      let comics = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      let writerNames = await accountManagerContract.getUserNames(result.writer);
      records.forEach((record, i) => {
        let comic = new Comic(
          result.comicAddress[i],
          record,
          result.totalPurchasedCount[i],
          result.episodeLastUpdatedTime[i],
          result.contentCreationTime[i]
        );
        comic.setWriter(result.writer[i], writerNames[i]);
        comics.push(comic.toJSON());
      });
      return comics;
    }
  }

  // 작품 조회
  async getComic(address) {
    let result = await this._contract.methods.getComic(address).call();
    result = Web3Utils.prettyJSON(result);
    let comic = new Comic(address, JSON.parse(result.records))
    comic.setWriter(result.writer, result.writerName);
    return comic.toJSON();
  };

  // 에피소드 목록 조회
  async getEpisodes(address) {
    let result = await this._contract.methods.getEpisodes(address).call();
    result = Web3Utils.prettyJSON(result);
    if (result.episodeIndex.length == 0) {
      return [];
    } else {
      let episodes = [];
      let records = JSON.parse(web3.utils.hexToUtf8(result.records));
      records.forEach((record, i) => {
        let episode = new Episode(
          result.episodeIndex[i],
          i + 1,
          record,
          result.price[i],
          result.isPurchased[i],
          undefined, undefined, undefined,
          result.episodeCreationTime[i]
        );
        episodes.push(episode.toJSON());
      });
      return episodes;
    }
  }

  async getEpisode(address, key) {
    let result = await this._contract.methods.getEpisode(address, key).call();
    let cuts = await this._contract.methods.getCuts(address, key).call();
    result = Web3Utils.prettyJSON(result);
    let episode = new Episode(
      key,
      0,
      JSON.parse(result.records),
      result.price,
      result.isPurchased,
      JSON.parse(cuts),
      new Date(Number(result.publishDate)),
      result.isPublished
    )
    return episode.toJSON();
  }

  // 작품 등록
  createComic(comic) {
    return this._contract.methods.createComic(JSON.stringify(comic)).send();
  }
  
  // 작품 수정
  updateComic(address, comic) {
    return this._contract.methods.updateComic(address, JSON.stringify(comic)).send();
  }

  // 에피소드 등록
  createEpisode(address, episode) {
    return this._contract.methods.createEpisode(
      address,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      BigNumber(episode.price * Math.pow(10, 18)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  // 에피소드 수정
  updateEpisode(address, episode) {
    return this._contract.methods.updateEpisode(
      address,
      episode.key,
      JSON.stringify({title: episode.title, thumbnail: episode.thumbnail}),
      JSON.stringify(episode.cuts),
      BigNumber(episode.price * Math.pow(10, 18)),
      episode.status,
      new Date(episode.publishedAt).getTime()
    ).send();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }
}

export default ApiContents;