//
//  NGShuaiDantVC.m
//  ddt
//
//  Created by wyg on 15/10/25.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "NGShuaiDantVC.h"

#define btnbasetag  330

@interface NGShuaiDantVC ()<UITextFieldDelegate,UITextViewDelegate>
{
    BOOL _textviewHasStart;
    LPickerView * _pickview;
    
    NSString * _kehusf;//客户身份
    NSArray *_kehusfArr;
    NSString * _zxstatus;//征信状态
    NSArray *_zxstatusArr;
}

@property (weak, nonatomic) IBOutlet UITextField *tf_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_age;
@property (weak, nonatomic) IBOutlet UIButton *btn_jine;
@property (weak, nonatomic) IBOutlet UIButton *btn_timelimit;
@property (weak, nonatomic) IBOutlet UIButton *btn_yewutype;
@property (weak, nonatomic) IBOutlet UIButton *btn_area;
@property (weak, nonatomic) IBOutlet UITextField *tf_jifen;

@property (weak, nonatomic) IBOutlet UIView *textviewbg;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *textviewDeleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *textviewNumLab;
@end

@implementation NGShuaiDantVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
}

-(void)initSubviews
{
    self.textviewbg.layer.borderWidth = 1;
    self.textviewbg.layer.borderColor = [UIColor lightTextColor].CGColor;
    self.textviewbg.layer.cornerRadius = 5;
    self.textviewbg.layer.masksToBounds = YES;
    
    UIButton *inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inputBtn.frame = CGRectMake(0, 0, 100, 30);
    inputBtn.backgroundColor = [UIColor lightGrayColor];
    [inputBtn setTitle:@"完成" forState:UIControlStateNormal];
    [inputBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    inputBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [inputBtn addTarget:self action:@selector(inputbtnAction) forControlEvents:UIControlEventTouchUpInside];
    self.textview.inputAccessoryView = inputBtn;
    [self textviewDetaultDisp:YES];

    _kehusfArr = @[@"上班",@"个体",@"企业"];
    _zxstatusArr =@[@"正常",@"异常",@"白户"];
}

//textview相关方法
-(void)inputbtnAction
{
    [self textviewDetaultDisp:YES];
    [self.textview resignFirstResponder];
}

-(void)textviewDetaultDisp:(BOOL)has
{
    if (has) {
        self.textview.text = @"详细说明: 户口所在地、社保、公积金、保单、资产情况、负债情况、工资形式、工资金额、工作年限、流水金额、借款用途、还款来源等详细说明。不要出现电话号码、QQ等其他联系方式";
        self.textview.textColor = [UIColor lightGrayColor];
            _textviewHasStart = NO;
    }
    else
    {
        self.textview.text = @"";
        self.textview.textColor = [UIColor blackColor];
            _textviewHasStart = YES;
    }
}


-(void)awakeFromNib
{
    self.hidesBottomBarWhenPushed = YES;

}

#pragma mark -- btn action
//选择客户身份和征信状态
-(void)kehuisf_select:(UIButton*)btn withstartfirst:(BOOL)isfirst
{
    NSInteger starttag = isfirst ? btnbasetag : btnbasetag+8;
    
    btn.selected = !btn.selected;
    for (int i =0; i < 3; i++) {
      UIButton *tmp = (UIButton *) [self.tableView viewWithTag:i + starttag];
        tmp == btn?1: (tmp.selected = NO);
    }
    
    isfirst ? ( {_kehusf = btn.selected? _kehusfArr[btn.tag - starttag]  :@"";}):({_zxstatus = btn.selected? _zxstatusArr[btn.tag - starttag]  :@"";});
    
    NSLog(@"...kehushenfen : %@",_zxstatus);
}


- (IBAction)btnClickAction:(UIButton *)sender {
    
    switch (sender.tag - btnbasetag) {
        case 0://客户身份
        case 1:
        case 2:[self kehuisf_select:sender withstartfirst:YES];break;
            
        case 8://征信状态
        case 9:
        case 10:[self kehuisf_select:sender withstartfirst:NO];break;
            
        case 11:[self textviewDetaultDisp:YES];break;
        default:break;
    }
    
    
}

//立即甩单操作
- (IBAction)submintAction:(id)sender {
    
    
    
}

#pragma mark -- UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!_textviewHasStart) {
        [self textviewDetaultDisp:NO];
    }
}

-(void)textViewDidChange:(UITextView *)textView{

    if (textView.text == 0) {
      [self textviewDetaultDisp:YES];
    }
    if (textView.text.length<=100) {
        self.textviewNumLab.text = [NSString stringWithFormat:@"%ld/100",textView.text.length];
    }else{
        self.textviewNumLab.text = @"100/100";
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location>=100) {
        return NO;
    }else{
        return YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end