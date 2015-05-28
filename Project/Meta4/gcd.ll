@x = common global i32 0, align 4
@y = common global i32 0, align 4

define i32 @gcd(i32 %a, i32 %b) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %a, i32* %2, align 4
  store i32 %b, i32* %3, align 4
  %4 = load i32* %2, align 4
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %6, label %8

; <label>:6                                       ; preds = %0
  %7 = load i32* %3, align 4
  store i32 %7, i32* %1
  br label %27

; <label>:8                                       ; preds = %0
  br label %9

; <label>:9                                       ; preds = %8
  %10 = load i32* %3, align 4
  %11 = icmp sgt i32 %10, 0
  br i1 %11, label %12, label %26

; <label>:12                                      ; preds = %9
  %13 = load i32* %2, align 4
  %14 = load i32* %3, align 4
  %15 = icmp sgt i32 %13, %14
  br i1 %15, label %16, label %20

; <label>:16                                      ; preds = %12
  %17 = load i32* %2, align 4
  %18 = load i32* %3, align 4
  %19 = sub nsw i32 %17, %18
  store i32 %19, i32* %2, align 4
  br label %24

; <label>:20                                      ; preds = %12
  %21 = load i32* %3, align 4
  %22 = load i32* %2, align 4
  %23 = sub nsw i32 %21, %22
  store i32 %23, i32* %3, align 4
  br label %24

; <label>:24                                      ; preds = %20, %16
  %25 = load i32* %2, align 4
  store i32 %25, i32* %1
  br label %27

; <label>:26                                      ; preds = %9
  br label %27

; <label>:27                                      ; preds = %6, %24, %26
  %28 = load i32* %1
  ret i32 %28
}

define void @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i8**, align 8
  store i32 %argc, i32* %1, align 4
  store i8** %argv, i8*** %2, align 8
  %3 = load i32* %1, align 4
  %4 = icmp sge i32 %3, 2
  br i1 %4, label %5, label %18

; <label>:5                                       ; preds = %0
  %6 = load i8*** %2, align 8
  %7 = getelementptr inbounds i8** %6, i64 0
  %8 = load i8** %7, align 8
  %9 = ptrtoint i8* %8 to i32
  store i32 %9, i32* @x, align 4
  %10 = load i8*** %2, align 8
  %11 = getelementptr inbounds i8** %10, i64 1
  %12 = load i8** %11, align 8
  %13 = ptrtoint i8* %12 to i32
  store i32 %13, i32* @y, align 4
  %14 = load i32* @x, align 4
  %15 = load i32* @y, align 4
  %16 = call i32 @gcd(i32 %14, i32 %15)
  %17 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str, i32 0, i32 0), i32 %16)
  br label %20

; <label>:18                                      ; preds = %0
  %19 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([33 x i8]* @.str1, i32 0, i32 0))
  br label %20

; <label>:20                                      ; preds = %18, %5
  ret void
}

declare i32 @printf(i8*, ...) #1

attributes #0 = { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
