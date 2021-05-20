<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <!--<el-form-item label="钱包地址:">
        <el-input v-model="form.wallet"></el-input>
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="onQueryUid">钱包转玩家UID</el-button>
      </el-form-item>-->
      
      <el-form-item label="玩家UID:">
        <el-input v-model="form.uid"></el-input>
      </el-form-item>
      
      <el-form-item label="数量:">
        <el-input v-model="form.count" type='number' placeholder="必须为数字"></el-input>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="onSubmit">金币充值</el-button>
      </el-form-item>
      <!--<el-form-item>
        <el-button type="primary" @click="onSubmit_zs">钻石充值</el-button>
      </el-form-item>-->
      
    </el-form>
  </div>
</template>

<script>
  import { setcoin , jiluchongzhi} from '@/api/game'
  export default {
    data() {
      return {
        listLoading: true,
				cnt: 0,
				chongzhiuid: 0,
        form: {
          count: '',
          uid: '',
          typ:1 ,  // 1金币,2钻石
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
        this.form.typ = 1
				
				this.chongzhiuid = this.form.uid
				this.cnt = this.form.count
				
        setcoin(this.form).then(response => {
        		console.log(response)
						
						this.handleModifyStatus()
						this.listLoading = false
						
						if(response.code == 20000){
							jiluchongzhi(this.chongzhiuid, this.cnt).then(response =>{
								console.log(response)
							})
						}
        }).catch(() => {
          this.listLoading = false
        })
      },

//    onSubmit_zs() {
//      this.listLoading = true
//      this.form.typ = 2
//      setcoin(this.form).then(response => {
//      		console.log(response)
//			this.handleModifyStatus()
//			this.listLoading = false
//      }).catch(() => {
//        this.listLoading = false
//      })
//    },  
    }
  }
</script>
