#import <Foundation/Foundation.h>
#import "Menu.h"

// KeyAuth деректері
#define KEYAUTH_NAME @"SoftboxiOS"
#define KEYAUTH_OWNER @"z1HNHScsTk"
#define KEYAUTH_SECRET @"ОРНЫНА_ҚҰПИЯ_КІЛТТІ_ЖАЗЫҢЫЗ"
#define KEYAUTH_VERSION @"1.0"

@implementation Menu

// Бұл функция қолданба іске қосылғанда ең бірінші жұмыс істейді
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showKeyAuthAlert];
    });
}

// Экранға кілт сұрайтын терезені (Alert) шығару
+ (void)showKeyAuthAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SoftboxiOS Активация"
                                                                   message:@"Жалғастыру үшін KeyAuth кілтін енгізіңіз:"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Кілтті осы жерге жазыңыз";
        textField.secureTextEntry = NO;
    }];
    
    UIAlertAction *activateAction = [UIAlertAction actionWithTitle:@"Белсендіру" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *keyField = alert.textFields.firstObject;
        NSString *enteredKey = keyField.text;
        
        if (enteredKey.length == 0) {
            [self showErrorAndExit:@"Кілт бос болмауы керек!"];
            return;
        }
        
        // Кілтті тексеруге сұраныс жіберу
        [self verifyKeyWithKeyAuth:enteredKey];
    }];
    
    [alert addAction:activateAction];
    
    // Терезені экранға шығару
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

// Интернет арқылы KeyAuth серверіне кілтті жіберіп тексеру (API сұраныс)
+ (void)verifyKeyWithKeyAuth:(NSString *)key {
    NSString *urlString = [NSString stringWithFormat:@"https://keyauth.win%@", 
                           key, KEYAUTH_VERSION, KEYAUTH_NAME, KEYAUTH_OWNER, KEYAUTH_SECRET];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorAndExit:@"Сервермен байланыс үзілді немесе интернет жоқ!"];
            });
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (json && [json[@"success"] boolValue] == YES) {
                // КІЛТ ДҰРЫС! Пайдаланушыға сәтті өткенін хабарлаймыз
                UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Сәтті!"
                                                                                      message:@"Кілт қабылданды, ойын іске қосылуда."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                [successAlert addAction:[UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:successAlert animated:YES completion:nil];
            } else {
                // КІЛТ ҚАТЕ! Ойынды жауып тастаймыз
                [self showErrorAndExit:@"Енгізілген кілт қате немесе уақыты біткен!"];
            }
        });
    }];
    
    [task resume];
}

// Қате болғанда қолданбаны жауып тастау функциясы
+ (void)showErrorAndExit:(NSString *)message {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Қате!"
                                                                          message:message
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"Шығу" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0); // Ойынды бірден жауып тастайды
    }];
    
    [errorAlert addAction:exitAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
}

@end
