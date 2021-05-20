<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">
    	  <el-form-item  label="可提现余额:">
        <el-input v-bind:readonly="true" v-model="form.jifen"></el-input>
      </el-form-item>
      <el-form-item  label="手机号:">
        <el-input v-model="form.phonenumber"></el-input>
      </el-form-item>
      <el-form-item  label="支付宝:">
        <el-input v-model="form.zhifubao"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">申请提现</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { gettixianjifen, shenqingtixian} from '@/api/tixian'
  export default {
    data() {
      return {
        listLoading: true,
        uid: localStorage.getItem("uid"),
        form: {
		  	jifen : '',
			phonenumber : '',
			zhifubao: '',
			count: 0,
        }
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        gettixianjifen(this.uid).then(response => {
        		console.log(JSON.stringify(response))
        		console.log(response)
        		var data = response.data
        		this.form.jifen = data.jifen
        		this.form.count = data.jifen
//      		this.form.phonenumber = data.phonenumber
//      		this.form.zhifubao = data.zhifubao
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '申请提现成功',
          type: 'success'
        })
      },
      onSubmit() {        
        this.listLoading = true
        console.log("form : " + JSON.stringify(this.form))
        console.log("form uid: " + JSON.stringify(this.uid))
        this.form.count = this.form.jifen
        shenqingtixian(this.form,this.uid).then(response => {
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
