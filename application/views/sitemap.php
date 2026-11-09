<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	$this->load->view('modules/mod_header'); 
?> 
<style>
.order-box {border-radius:10px;margin-bottom:15px;cursor:pointer;}
.order-box:hover {box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;}
.order-box p {margin:0;}
</style>

<!-- 8 mã màu phù hợp #E3F6FF #ebf3ff #f2f0ff #e3faf5 #fff6e6 #FFE5F1 #E0F4FF #EDF6E5 -->
<!-- page content -->
			<div class="right_col" role="main">
				<div class="">
					
					<div class="row">
						<div class="col-md-12 col-sm-12 pd0">
							<div class="x_panel" style="height: calc(100vh - 120px);overflow-y: scroll;">
								<?php echo $content; ?>
							</div>
						</div>
					</div>

					
				</div>
			</div>
			<!-- /page content --> 
	
<?php
	$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>