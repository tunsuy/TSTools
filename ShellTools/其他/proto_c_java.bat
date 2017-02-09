@echo "compile C++ files"
FOR %%i IN (proto_def\*) DO (
    .\protoc  -I=.\proto_def  --cpp_out=.\cpp_out    %%i
)


@echo "compile JAVA files"
mkdir tmp
cd proto_def
FOR %%i IN (*) DO (
    echo option optimize_for = LITE_RUNTIME; >>  ..\tmp\%%i
    type %%i >> ..\tmp\%%i
)
cd ..
FOR %%i IN (tmp\*) DO (
    .\protoc  -I=.\tmp  --java_out=.\java_out  %%i
)
rmdir tmp /s /q


@echo "copy .cc .h files to iOS directory"
copy  cpp_out\*  ..\iOS\MOA\MOA\Net\ProtoDef\
FOR %%i IN (..\iOS\MOA\MOA\Net\ProtoDef\*) DO (
    .\sed -i -e "s/namespace\ google /namespace\ google_moa /g" %%i
    .\sed -i -e "s/google::protobuf/google_moa::protobuf/g"     %%i
)


pause