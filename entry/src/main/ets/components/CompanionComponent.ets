@Component
export struct CompanionComponent {
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;

  // 根据累计番茄数返回树的表情符号（分5个阶段）
  getTreeEmoji(): string {
    if (this.totalTomatoCount < 10) return '🌱';
    if (this.totalTomatoCount < 50) return '🌿';
    if (this.totalTomatoCount < 200) return '🌳';
    if (this.totalTomatoCount < 500) return '🌲';
    return '🎄';
  }

  getStageText(): string {
    if (this.totalTomatoCount < 10) return '种子阶段';
    if (this.totalTomatoCount < 50) return '幼苗阶段';
    if (this.totalTomatoCount < 200) return '小树阶段';
    if (this.totalTomatoCount < 500) return '大树阶段';
    return '参天大树';
  }

  build() {
    Column() {
      // 天数
      Text(`连续学习 ${this.continuousDays} 天`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 24 })

      // 树（大号表情）
      Text(this.getTreeEmoji())
        .fontSize(120)
        .margin({ bottom: 16 })

      // 阶段名称
      Text(this.getStageText())
        .fontSize(18)
        .fontColor('rgba(255,255,255,0.7)')

      // 累计番茄数
      Text(`累计完成 ${this.totalTomatoCount} 个番茄`)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.4)')
        .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}