<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <el-form-item label="钱包地址:">
        <el-input v-model="form.wallet"></el-input>
      </el-form-item>
      

        <el-form-item label="钱包类型:" class="postInfo-container-item">
            <template>
            <el-select v-model="form.wallettype" placeholder="请选择">
              <el-option
                v-for="item in wallettype"
                :key="item.value"
                :label="item.label"
                :value="item.value">
              </el-option>
            </el-select>
          </template>
        </el-form-item>


      <el-form-item>
        <el-button type="primary" @click="onQueryUid">钱包转玩家UID</el-button>
      </el-form-item>
      
      <el-form-item label="玩家UID:">
        <el-input v-model="form.uid"></el-input>
      </el-form-item>
      
      <el-form-item label="USDT数量[负数为减-]:">
        <el-input v-model="form.usdt" type='number' placeholder="必须为数字"></el-input>
      </el-form-item>
      
      <!--<el-form-item label="是否参加给上级代理返现:">
	  	<el-switch
		  v-model="form.checked"
		  active-color="#13ce66"
		  inactive-color="#ff4949" >
		</el-switch>
      </el-form-item>-->
      
      <el-form-item>
        <el-button type="primary" @click="onSubmit">充值usdt</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { chongzhiusdt,wallet2uid } from '@/api/setting'
  export default {
    data() {
      return {
        listLoading: true,
        wallettype: [{
          value: '0',
          label: 'usdt'
        }, {
          value: '1',
          label: '以太坊'
        }],
        form: {
          wallet: '',
          wallettype:'',
          usdt: '',
          uid: '',
          checked: true
        }
      }
    },
    methods: {
      handleModifyStatus() {
        this.$message({
          message: '操作成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        chongzhiusdt(this.form).then(response => {
        		console.log(response)
			this.handleModifyStatus()
			this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      onQueryUid(){
      	this.listLoading = true
       	wallet2uid(this.form).then(response => {
        		console.log(response)
//      		if(response.data != null && respones.data['uid'] != null ){
//      			console.log('data : ' + response.data)
//      			console.log('uid:' + response.data.uid)
//      			this.form.uid = response.data.uid
//      		}
        		this.form.uid = response.data.uid
        		
			this.handleModifyStatus()
			this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
     }     
    }
  }
</script>
