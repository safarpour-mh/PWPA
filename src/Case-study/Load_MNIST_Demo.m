%% بارگذاری و نمایش داده‌های MNIST در متلب (با 6000 نمونه)

% --- بارگذاری داده‌ها ---
fprintf('در حال بارگذاری داده‌های MNIST...\n');
[XTrain, YTrain] = digitTrain4DArrayData; % 👈 داده اصلی: 60000 نمونه
[XTest, YTest] = digitTest4DArrayData;

% --- تبدیل به فرمت 2D ---
XTrain = reshape(XTrain, 28*28, [])'; % 👈 حالا [60000 x 784]
XTest  = reshape(XTest,  28*28, [])';
YTrain = double(YTrain);
YTest  = double(YTest);

% --- نرمال‌سازی ---
XTrain = XTrain / 255.0;
XTest  = XTest  / 255.0;

% --- ⚠️ کاهش حجم داده برای تست سریع (اما با 6000 نمونه) ---
sample_size = 5000;
XTrain = XTrain(1:sample_size, :); % 👈 حالا خط 21 بدون خطا اجرا می‌شود
YTrain = YTrain(1:sample_size);
XTest  = XTest(1:sample_size, :);
YTest  = YTest(1:sample_size);

% --- نمایش اطلاعات ---
fprintf('✅ بارگذاری با موفقیت انجام شد!\n');
fprintf('ابعاد XTrain: [%d × %d]\n', size(XTrain, 1), size(XTrain, 2)); % باید بگوید [6000 x 784]
fprintf('ابعاد YTrain: [%d × 1]\n', length(YTrain));