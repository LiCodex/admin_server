import request from '@/utils/request'

export function lunpan(name1, percent1, count1, name2, percent2, count2, name3, percent3, count3, name4, percent4, count4, name5, percent5, count5, name6, percent6, count6, name7, percent7, count7, name8, percent8, count8, name9, percent9, count9, name10, percent10, count10, name11, percent11, count11, name12, percent12, count12) {
  var s = 'name1=' + name1 + '&count1=' + count1 + '&percent1=' + percent1
    + '&name2=' + name2 + '&count2=' + count2 + '&percent2=' + percent2
    + '&name3=' + name3 + '&count3=' + count3 + '&percent3=' + percent3
    + '&name4=' + name4 + '&count4=' + count4 + '&percent4=' + percent4
    + '&name5=' + name5 + '&count5=' + count5 + '&percent5=' + percent5
    + '&name6=' + name6 + '&count6=' + count6 + '&percent6=' + percent6
    + '&name7=' + name7 + '&count7=' + count7 + '&percent7=' + percent7
    + '&name8=' + name8 + '&count8=' + count8 + '&percent8=' + percent8
    + '&name9=' + name9 + '&count9=' + count9 + '&percent9=' + percent9
    + '&name10=' + name10 + '&count10=' + count10 + '&percent10=' + percent10
    + '&name11=' + name11 + '&count11=' + count11 + '&percent11=' + percent11
    + '&name12=' + name12 + '&count12=' + count12 + '&percent12=' + percent12
  console.log(s)
  return request({
    url: process.env.BASE_API + '/setlunpan',
    method: 'post',
    data: s
  })
}

export function setnotice(data) {
  console.log(data.count)
  return request({
    url: process.env.BASE_API + '/set_notice_scroll?notice=' + data.context,
    method: 'get'
  })
}

export function getnotice() {
  return request({
    url: process.env.BASE_API + '/get_notice_scroll_ht',
    method: 'get'
  })
}

//export function setrule(data) {
//console.log(data.text)
//var d = 'rule=' + data.text
//return request({
//  url: process.env.BASE_API + '/setrule',
//  method: 'post',
//  data: d
//})
//}
//
//export function getrule() {
//return request({
//  url: process.env.BASE_API + '/getrule',
//  method: 'get'
//})
//}

export function setrule(data) {
  console.log(data.text)
  var d = 'rule=' + data.text
  return request({
    url: process.env.BASE_API + '/setrule?' + d,
    method: 'post',
    data: d
  })
}

export function getrule() {
  return request({
    url: process.env.BASE_API + '/getrule',
    method: 'get'
  })
}

export function setrumen(data) {
  console.log(data.count)
  var d = 'count=' + data.count + '&title=' + data.title
  return request({
    url: process.env.BASE_API + '/setrumen',
    method: 'post',
    data: d
  })
}

export function getrumen() {
  return request({
    url: process.env.BASE_API + '/getrumen',
    method: 'get'
  })
}

// 德州里设置系统公告
export function setchangjian(data) {
  console.log(data.count)
  var d = 'count=' + data.content + '&title=' + data.title
  return request({
    url: process.env.BASE_API + '/setchangjian',
    method: 'post',
    data: d
  })
}

// 德州里获取系统公告
export function getchangjian() {
  return request({
    url: process.env.BASE_API + '/getchangjian',
    method: 'get'
  })
}

// 德州 删除系统公告
export function delchangjian(id) {
	console.log('wentiid = ' + id)
  return request({
    url: process.env.BASE_API + '/delchangjian?id=' + id,
    method: 'get'
  })
}


export function setfuwu(data) {
  console.log(data.count)
  var d = 'count=' + data.count + '&title=' + data.title
  return request({
    url: process.env.BASE_API + '/setfuwu',
    method: 'post',
    data: d
  })
}

export function getfuwu() {
  return request({
    url: process.env.BASE_API + '/getfuwu',
    method: 'get'
  })
}


//export function sethelp(data) {
//console.log(JSON.stringify(data))
//var d = 'rumen=' + data.rumen + '&changjian=' + data.changjian + '&service='+  data.service
//return request({
//  url: process.env.BASE_API + '/sethelp',
//  method: 'post',
//  data: d
//})
//}
//
//export function gethelp() {
//return request({
//  url: process.env.BASE_API + '/gethelp',
//  method: 'get'
//})
//}


export function setchoushui(data) {
	console.log(JSON.stringify(data))
	return request({
	    url: process.env.BASE_API + '/setchoushui?' + data,
	    method: 'get'
	})
}

export function getchoushui() {
  return request({
    url: process.env.BASE_API + '/getchoushui',
    method: 'get'
  })
}

export function setseatcondition(data) {
	console.log(JSON.stringify(data))
	return request({
	    url: process.env.BASE_API + '/setseatcondition?seatcond=' + data.seatcond,
	    method: 'get'
	})
}

export function getseatcondition() {
  return request({
    url: process.env.BASE_API + '/getseatcondition',
    method: 'get'
  })
}


export function setshenglv(data) {
	console.log(JSON.stringify(data))
	return request({
	    url: process.env.BASE_API + '/setshenglv?' + data,
	    method: 'get'
	})
}

export function getshenglv() {
  return request({
    url: process.env.BASE_API + '/getshenglv',
    method: 'get'
  })
}
// usdt充值
export function chongzhiusdt(data) {
	console.log(JSON.stringify(data))
  var url = process.env.BASE_API + '/chongzhiusdt?usdt=' + data.usdt + '&rechargeuid=' + data.uid + "&enablefanxian=" + data.checked
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}
// usdt充值记录
export function getchongzhiusdtrecord(finduid) {
	// uid -> wallet
  return request({
    url: process.env.BASE_API + '/getchongzhiusdtrecord?finduid=' + finduid,
    method: 'get'
  })
}

//export function getchongzhilist(finduid) {
//return request({
//  url: process.env.BASE_API + '/getchongzhilist?finduid=' + finduid,
//  method: 'get'
//})
//}

// 充值TBK
export function chongzhifangka(data) {
	console.log(JSON.stringify(data))
  var url = process.env.BASE_API + '/chongzhifangka?count=' + data.count + '&chongzhiuid=' + data.uid
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}
// 获取充值 tbk 记录
export function getchongzhitbkrecord(fuid) {
	// uid -> wallet
  return request({
    url: process.env.BASE_API + '/getchongzhitbkrecord?finduid=' + fuid,
    method: 'get'
  })
}


export function setaboutme(data) {
  console.log(data.count)
  var d = 'count=' + data.count + '&title=' + data.title
  return request({
    url: process.env.BASE_API + '/setaboutme',
    method: 'post',
    data: d
  })
}

export function getaboutme() {
  return request({
    url: process.env.BASE_API + '/getaboutme',
    method: 'get'
  })
}


export function wallet2uid(data) {
  console.log(data)

  var typ = data.wallettype
  if (parseInt(typ) == 1) {
    // yi taifang
    return request({
      url: process.env.BASE_API + '/ethwallet2uid?wallet='+data.wallet,
      method: 'get'
    })

  }else{
      return request({
        url: process.env.BASE_API + '/wallet2uid?wallet='+data.wallet,
        method: 'get'
      })
  }
}

export function setimgserver(img) {
  return request({
    url: process.env.IMG_API + '/upload',
    method: 'post',
    data: 'imagedata=' + img
  })
}

// 玩家充值(钻石,金币)
export function playerchongzhi(data) {
	console.log(JSON.stringify(data))
  var url = process.env.BASE_API + '/adminchongzhi?count=' + data.count + '&chongzhiuid=' + data.uid + "&typ=" + data.typ
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}