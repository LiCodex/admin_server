<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="120px">

      <!--<el-form-item label="游戏模式">
        <el-select v-model="form.type" placeholder="请选游戏模式">
          <el-option label="斗地主" value="doudizhu" selected = "selected" ></el-option>
          <el-option label="小九" value="xiaojiu" selected = "selected" ></el-option>
        </el-select>
      </el-form-item>-->

      <el-form-item label="俱乐部ID:" >
 			<span :class="clubkey">{{form.hallkey}}</span>
      </el-form-item>

      <el-form-item label="俱乐部昵称">
        <el-input v-model="form.hallname" type='string' placeholder="请输入俱乐部昵称"></el-input>
      </el-form-item>

      <el-form-item label="俱乐部简介">
        <el-input v-model="form.hallintroduce" type='string' placeholder="请输入俱乐部简介"></el-input>
      </el-form-item>

      <el-form-item label="馆主ID">
        <el-input v-model="form.guanid" type='string' placeholder="请输入馆主ID"></el-input>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="onSubmit">立即创建</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { createclub } from '@/api/club'
  import { getToken } from '@/utils/auth'
  export default {
  	
    data() {
      return {
      	clubkey:'clubkey_sty',
        list: null,
        listLoading: true,
        isReadOnly:true,
        form: {
          type: 'dezhou',
          hallkey: '',
          owner: null,
          hallname: null,
          hallintroduce: null,
          guanid: null,
          token: getToken()
        }
      }
    },
    methods: {
    		handleModifyStatus() {
        this.$message({
          message: '设置成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        createclub(this.form).then(response => {
        		console.log("reutrn data:" +  JSON.stringify(response.data))
        		var data = response.data
        		if(data != null &&data.hallkey != null){
        			this.form.hallkey = data.hallkey
        		}
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      }
    }
  }
</script>

<style scoped>
  .edit-input {
    padding-right: 100px;
  }
  .cancel-btn {
    position: absolute;
    right: 15px;
    top: 13px;
  }
  .clubkey_sty{
  	color: blue;
  	font-size: larger;
  	font-style: italic;
  	background-color:red
  }
  .tongji{
  	font-size: larger;
  	color: red;
  }
</style>
