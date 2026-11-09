<!-- page content -->
<form name="frm_main" method="post" action="<?php echo $link_page; ?>"> 
        <div class="right_col" role="main">
          <div class="">
            <div class="page-title">
              <div class="title_left">
                <h3><small></small></h3>
              </div>

              <div class="title_right text-right">

              </div>
            </div>

            <div class="clearfix"></div>

            <div class="row">
              <div class="col-md-12 col-sm-12 ">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>PHÂN QUYỀN NGƯỜI DÙNG</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                     
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                      <div class="row">
                          <div class="col-sm-12">
                            <div class="card-box table-responsive">
							<div class="top-filter" style="">
									<input name="btn_header_add" type="button" class="btn btn-primary" value="Thêm mới" 
										onclick="js_SetSubmitButtonClick(this.form,'btn_add');" class="button"/>	
									<input name="btn_delete" type="button" class="btn btn-danger" value="Xóa các mục đã chọn"  
										   onclick="js_CheckValidBeforeDeleteListview(this.form,'chkItems',
												'<?php echo $msg_confirm_before_delete; ?>' ,
												'<?php echo $msg_invalid_before_delete;  ?>' )" class="button" />
									<input type="hidden" name="hidden_button"  id="hidden_button"/>	
							</div>
							<table id="datatable" class="table table-striped table-bordered" style="width:100%">
							  <thead>
								<tr>
								  <th style=>
									<div class="d-flex align-items-center justify-content-center">
									 <span>#</span>
									 <span>	
										<input name="chkItems" type="checkbox" class="checkbox" 
										   onclick="js_CheckAllClick(this,this.name);" />
										</span>
									</div>	
								  </th>	
								  <th>Tên</th>
								  <th>Ghi chú</th>
								  <th>Ngày tạo</th>
								  <th>Ngày sửa</th>
								</tr>
							  </thead>
								<tbody>
								<?php $i=1; 
								foreach($data_view as $data){
								?>
								  <tr>
									 <td>
										 <div class="d-flex align-items-center justify-content-center">
										 <span><?php echo $i; ?></span>	
										 <span>	
											<input name="chk[]" type="checkbox" value="<?php echo $data['nid']; ?>"
												id="chkItems" class="checkbox" 								   
												onclick="js_CheckItemClick(this, 'chkItems','chkItems');" />
											</span>	
										 </div>
									 </td>
									 <td class="text-left"><a href="<?php echo base_url() . 'index.php/do_user_type/f_edit/' . $data['nid']; ?>"><?php echo Fview_text($data['cuser_type']); ?></a></td>   
									 <td><?php echo Fview_text($data['cnote']); ?></td>
									 <td><?php echo Fview_date($data['ddate01']); ?></td>
									 <td><?php echo Fview_date($data['ddate02']); ?></td>	
								  </tr>
								<?php $i++;} ?>
							  </tbody>
							</table>
						  </div>
						  </div>
					  </div>
					</div>
                </div>
              </div>

			</div>
          </div>
        </div>
		</form>
        <!-- /page content -->