<!-- page content -->
<form name="frm_main" method="post" action="<?php echo $link_page; ?>"> 
        <div class="right_col" role="main">
          <div class="">
            <div class="page-title cb">
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
                    <h2>QUẢN LÝ CẤU HÌNH</h2>
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
							<table id="datatable" class="table table-striped table-bordered" style="width:100%">
							  <thead>
								<tr>
								 <th class="text-center">#</th>
								 <th><?php echo $lbl_cname;?></th>
								 <th><?php echo $lbl_cvalue;?></th>
								 <th><?php echo $lbl_cnote;?></th>
								 <th><?php echo $lbl_date01 ?></th>
								 <th>Ngày sửa</th>
							  </tr>
							  </thead>
								<tbody>
								<?php $i=1; 
									foreach($data_view as $data) {
								?>
							  <tr>
								 <td><?php echo $i; ?></td>
								 <td class="text-left"><a href="<?php echo base_url() . 'index.php/do_config/f_edit/' . $data['nid']; ?>"><?php echo Fview_text($data['cname']); ?></a></td>   
								 <td><?php echo Fview_text($data['cvalue']); ?></td>					 
								 <td><?php if(strlen($data['cnote'])>35) echo Fview_text(substr($data['cnote'],0,35)).'...';else  echo Fview_text($data['cnote']); ?></td>
								 <td><?php echo Fview_date($data['ddate01']); ?></td>
								 <td><?php echo Fview_date($data['ddate02']); ?></td>
							  </tr>
								<?php $i++;} ?>
							  </tbody>
							</table>
							
							<table class="table table-filter" cellspacing="1">
								<tr>						
									<td class="d-flex">	
												
									</td>
									
									<td>
										<div class="d-flex justify-content-end align-items-center">	
											<label class="mg0"><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;
											
											<input class="form-control" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>"
													style="text-align:center;height:31px;width:80px;" />&nbsp;
											
											<input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form,this.name);" class="btn btn-info btn-sm"/>
										</div>
									</td>
									
									<td>
										<div class="d-flex justify-content-end align-items-center">		
											<?php if($txt_current_page > 1): ?>
											<input class="btn btn-secondary btn-sm" name="btn_previous" type="button" value="<<" 
												onclick="js_SetSubmitButtonClick(this.form,'btn_previous');"/>&nbsp;	
											<?php endif; ?>
											
											<label class="mg0"><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;
											
											<?php if($txt_current_page < $txt_total_page): ?>
											<input class="btn btn-secondary btn-sm" name="btn_next" type="button" value=">>" 
												onclick="js_SetSubmitButtonClick(this.form,'btn_next');"/>&nbsp;
											<?php endif ?>
													
											<input class="form-control" name="txt_current_page" type="text" value="<?php echo $txt_current_page ; ?>"
												style="text-align:center;height:31px;width:50px;" size="5" />&nbsp;
												   
											<input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form,this.name);" class="btn btn-info btn-sm" />
										</div>	
									</td>
								</tr>					
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
		<input type="hidden" name="hidden_button"  id="hidden_button"/>	
		</form>
        <!-- /page content -->