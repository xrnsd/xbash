#!/opt/homebrew/bin/bash
# 定义源目录和目标目录
SOURCE="/Users/myname/learnData/"
DESTINATION="/Volumes/data/English/learnData/"

# 检查移动硬盘是否已挂载
if [ -d "$DESTINATION" ]; then
    # 使用 rsync 进行增量备份
    # -a: 归档模式, -v: 详细, -z: 压缩, --delete: 删除目标中源目录已删除的文件
    rsync -avz --delete "$SOURCE" "$DESTINATION"
    echo "${SOURCE} 备份于 $(date) 成功完成" >> ~/.backup_log.txt
else
    echo "备份失败：未找到移动硬盘 $(date)" >> ~/.backup_log.txt
fi
