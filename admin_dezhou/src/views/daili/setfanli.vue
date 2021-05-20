<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">
    	  <el-form-item  label="上级给我设置的返利%:">
        <el-input v-bind:readonly="true" v-model="form.shangjifanli"></el-input>
      </el-form-item>
      <el-form-item  label="给下结设置返利:">
        <el-input v-model="form.fanli"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">立即设置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { getfanli, setfanli} from '@/api/tixian'
  export default {
    data() {
      return {
        listLoading: true,
        uid: localStorage.getItem("uid"),
        form: {
		  	shangjifanli : 0,
			fanli : 0,
        }
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        getfanli(this.uid).then(response => {
        		console.log(JSON.stringify(response))
        		console.log(response)
        		var data = response.data
        		this.form.shangjifanli = data.shangjifanli || 0
        		this.form.fanli = data.fanli || 0
        		
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '设置成功',
          type: 'success'
        })
      },
      onSubmit() {        
        this.listLoading = true
		this.form.fanli = parseInt(this.form.fanli)
		setfanli(this.form,this.uid).then(response => {
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
