import { DailyTomatoRecord } from '../common/StudyRoomTypes';

@Component
export struct StatsComponent {
  @Prop todayTomatoCount: number = 0;
  @Prop totalFocusMinutes: number = 0;
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;
  @Prop targetTomatoes: number = 6;
  @Prop contributionDays: DailyTomatoRecord[] = [];
  @Prop statsVersion: number = 0;

  private getSafeTarget(): number {
    if (this.targetTomatoes <= 0) {
      return 1;
    }
    return this.targetTomatoes;
  }

  private getProgressValue(): number {
    return Math.min(100, Math.round(this.todayTomatoCount / this.getSafeTarget() * 100));
  }

  private getProgressText(): string {
    if (this.todayTomatoCount >= this.getSafeTarget()) {
      return '今日目标已完成';
    }
    const remain = this.getSafeTarget() - this.todayTomatoCount;
    return `还差 ${remain} 个番茄达成今日目标`;
  }

  private getFocusHourLabel(): string {
    if (this.totalFocusMinutes < 60) {
      return `${this.totalFocusMinutes} 分钟`;
    }
    const hours = Math.floor(this.totalFocusMinutes / 60);
    const minutes = this.totalFocusMinutes % 60;
    if (minutes === 0) {
      return `${hours} 小时`;
    }
    return `${hours} 小时 ${minutes} 分`;
  }

  private getHeatmapWeeks(): DailyTomatoRecord[][] {
    const weeks: DailyTomatoRecord[][] = [];
    let week: DailyTomatoRecord[] = [];
    this.contributionDays.forEach((item: DailyTomatoRecord) => {
      week.push(item);
      if (week.length === 7) {
        weeks.push(week);
        week = [];
      }
    });
    if (week.length > 0) {
      weeks.push(week);
    }
    return weeks;
  }

  private getContributionLevel(count: number): number {
    if (count <= 0) {
      return 0;
    }
    if (count === 1) {
      return 1;
    }
    if (count <= 3) {
      return 2;
    }
    if (count <= 5) {
      return 3;
    }
    return 4;
  }

  private getContributionColor(count: number): string {
    const level = this.getContributionLevel(count);
    if (level === 0) {
      return 'rgba(255,255,255,0.10)';
    }
    if (level === 1) {
      return '#9BE9A8';
    }
    if (level === 2) {
      return '#40C463';
    }
    if (level === 3) {
      return '#30A14E';
    }
    return '#216E39';
  }

  private getActiveDaysCount(): number {
    let activeDays = 0;
    this.contributionDays.forEach((item: DailyTomatoRecord) => {
      if (item.count > 0) {
        activeDays = activeDays + 1;
      }
    });
    return activeDays;
  }

  build() {
    Column({ space: 14 }) {
      Text(`${this.statsVersion}`)
        .width(0)
        .height(0)
        .opacity(0)

      Row() {
        Column({ space: 6 }) {
          Text('学习统计')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.getProgressText())
            .fontSize(12)
            .fontColor('rgba(234,239,244,0.70)')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(`${this.todayTomatoCount}/${this.getSafeTarget()}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A2432')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FFD878')
          .borderRadius(16)
      }
      .width('100%')

      Column({ space: 10 }) {
        Row() {
          Text('最近 70 天')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.62)')

          Blank()

          Text(`${this.getActiveDaysCount()} 天有记录`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#9BE9A8')
        }
        .width('100%')

        Row({ space: 6 }) {
          ForEach(this.getHeatmapWeeks(), (week: DailyTomatoRecord[]) => {
            Column({ space: 5 }) {
              ForEach(week, (item: DailyTomatoRecord) => {
                Column()
                  .width('100%')
                  .aspectRatio(1)
                  .backgroundColor(this.getContributionColor(item.count))
                  .borderRadius(3)
              }, (item: DailyTomatoRecord) => item.date)
            }
            .layoutWeight(1)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 6, bottom: 6 })

        Row({ space: 5 }) {
          Text('少')
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.46)')

          ForEach([0, 1, 2, 3, 4], (level: number) => {
            Column()
              .width(10)
              .height(10)
              .backgroundColor(this.getContributionColor(level === 0 ? 0 : level))
              .borderRadius(2)
          })

          Text('多')
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.46)')

          Blank()

          Text(`目标 ${this.getProgressValue()}%`)
            .fontSize(11)
            .fontColor('rgba(255,242,194,0.78)')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .backgroundColor('rgba(255,255,255,0.06)')
      .borderRadius(18)

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          this.buildStatItem('今日番茄', `${this.todayTomatoCount} 个`, '#FFD878')
          this.buildStatItem('今日专注', this.getFocusHourLabel(), '#9EE2FF')
        }
        .width('100%')

        Row({ space: 10 }) {
          this.buildStatItem('连续学习', `${this.continuousDays} 天`, '#B8F0C0')
          this.buildStatItem('累计番茄', `${this.totalTomatoCount} 个`, '#FFB26B')
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('90%')
    .padding(16)
    .backgroundColor('rgba(30,34,48,0.62)')
    .borderRadius(24)
    .margin({ bottom: 16 })
  }

  @Builder
  private buildStatItem(title: string, value: string, accentColor: string) {
    Row() {
      Column()
        .width(3)
        .height(34)
        .backgroundColor(accentColor)
        .borderRadius(2)
        .margin({ right: 10 })

      Column({ space: 6 }) {
        Text(value)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(1)

        Text(title)
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.58)')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(16)
  }
}
