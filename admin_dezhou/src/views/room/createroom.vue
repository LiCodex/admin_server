<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">
    	 <el-form-item  label="房间名字:">
        <el-input v-model="form.name"></el-input>
      </el-form-item>
     <el-form-item  label="房间型号:">
        <template>
		  <el-radio v-model="form.size" label="0">微型</el-radio>
		  <el-radio v-model="form.size" label="1">小型</el-radio>
		  <el-radio v-model="form.size" label="2">中型</el-radio>
		  <el-radio v-model="form.size" label="3">大型</el-radio>
		</template>
      </el-form-item>
    	  <el-form-item  label="游戏时间:">
        <template>
		  <el-radio v-model="form.time" label="30">30分钟</el-radio>
		  <el-radio v-model="form.time" label="60">60分钟</el-radio>
		  <el-radio v-model="form.time" label="90">90分钟</el-radio>
		  <el-radio v-model="form.time" label="120">120分钟</el-radio>
		</template>
      </el-form-item>
      <el-form-item  label="玩家人数(2~9):">
        <el-input type='number'   v-model="form.chaircount"></el-input>
      </el-form-item>
      <el-form-item  label="房间最小金币:">
        <el-input type='number'  v-model="form.mincoin"></el-input>
      </el-form-item>
      <el-form-item  label="房间最大金币:">
        <el-input type='number'  v-model="form.maxcoin"></el-input>
      </el-form-item>
      <el-form-item  label="最大上分额度:">
        <el-input type='number'  v-model="form.shangfen"></el-input>
      </el-form-item>
      <el-form-item  label="大盲注:">
        <el-input type='number'  v-model="form.damang"></el-input>
      </el-form-item>
      <el-form-item  label="小盲注:">
        <el-input type='number'  v-model="form.xiaomang"></el-input>
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="onSubmit">创建房间</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { createroom } from '@/api/game'
  export default {
    data() {
      return {
        listLoading: true,
        uid: localStorage.getItem("uid"),
        form: {
		  	time :  120,
			chaircount : 8,
			mincoin: 0,
			maxcoin: 400,
			shangfen: 400,
			damang: 2,
			xiaomang: 1,
			tp : "putongdezhou",
			name : "",
			size : 0,
        }
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
//      gettixianjifen(this.uid).then(response => {
//      		console.log(JSON.stringify(response))
//      		console.log(response)
//      		var data = response.data
//      		this.form.jifen = data.jifen
//      		this.form.count = data.jifen
//        this.listLoading = false
//      }).catch(() => {
//        this.listLoading = false
//      })
      },
      handleModifyStatus() {
        this.$message({
          message: '创建房间成功',
          type: 'success'
        })
      },
      onSubmit() {        
        this.listLoading = true
        console.log("form : " + JSON.stringify(this.form))
        console.log("form uid: " + JSON.stringify(this.uid))
        
        this.form.size = parseInt(this.form.size)
        this.form.time = parseInt(this.form.time)
        this.form.chaircount = parseInt(this.form.chaircount)
        this.form.mincoin = parseInt(this.form.mincoin)
        this.form.maxcoin = parseInt(this.form.maxcoin)
        this.form.maxcoin = parseInt(this.form.maxcoin)
        this.form.shangfen = parseInt(this.form.shangfen)
        this.form.damang = parseInt(this.form.damang)
        this.form.xiaomang = parseInt(this.form.xiaomang)
        
        if(this.form.name.length == 0){
        		alert("房间名不能为空")
        		return;
        }
        if(this.form.size<0 && this.form.size > 3){
        		alert("房间型号不正确")
        		return;
        }
        if(this.form.chaircount <2 && this.form.chaircount >9 ){
        		alert("填写的人数不正确")
        		return;
        }
		if(this.form.mincoin <=0 ){
        		alert("房间金币不能小于0")
        		return;
        }
		if(this.form.maxcoin <= 0 || this.form.maxcoin <= this.form.mincoin){
			alert("房间最大的金币数不能为0或少于最小金币数")
			return
		}
		if(this.form.shangfen <=0 ){
        		alert("上分不能为0")
        		return;
       }
		if(this.form.damang <= 0 || this.form.xiaomang <= 0){
			alert("大小盲注不能为0")
			return
		}

        createroom(this.form,this.uid).then(response => {
        		console.log(response)
			this.handleModifyStatus()
			this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
        
      },
      obj_contact(obj) {
        var s = ''
        for (var k in obj) {
          var v = obj[k]
          if (s == '') {
            s += k + '=' + v
          } else {
            s += '&' + k + '=' + v
          }
        }
        return s
      },
      setvalues(form,data){
      	console.log(JSON.stringify(data))
      	var d = data[form.index]
      	console.log(JSON.stringify(d))
      	
		form.ziyoumin = d.ziyoumin
		form.jishu = d.jishu
      }
    }
  }
</script>
