import util from '@ohos.util';
import lottie, { AnimationItem } from '@ohos/lottie';
import media from '@ohos.multimedia.media';
import { CompanionDailyTask, CompanionProgress } from '../common/StudyRoomTypes';

interface CompanionStage {
  level: number;
  title: string;
  subtitle: string;
  hint: string;
  unlockText: string;
  animationName: string;
  accentColor: string;
  glowColor: string;
  badgeText: string;
  skinName: string;
  talkLines: string[];
}

@Component
export struct CompanionComponent {
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;
  @Prop todayTomatoCount: number = 0;
  @Watch('onStatsVersionChange') @Prop statsVersion: number = 0;
  @Prop animationName: string = 'cat_sleep.json';
  @Watch('onTaskBoardChange') @Prop dailyTasks: CompanionDailyTask[] = [];
  @Prop showLevelUpModal: boolean = false;
  @Prop unlockedStageTitle: string = '';
  @Prop unlockedStageReward: string = '';
  @Prop latestClaimSummary: string = '';
  @Prop accentColor: string = '#FFD878';
  onClaimTaskReward: (taskId: string) => void = () => {};
  onGoToTask: (taskId: string) => void = () => {};
  onDismissLevelUp: () => void = () => {};
  @Watch('onProgressChange') @Prop companionProgress: CompanionProgress = {
    level: 1,
    totalAffinity: 0,
    currentLevelAffinity: 0,
    nextLevelAffinity: 100
  };

  @State currentTalkLine: string = '';
  @State talkBubbleVisible: boolean = false;
  @State talkBubbleOpacity: number = 0;
  @State talkBubbleScale: number = 0.9;
  @State petScale: number = 1;
  @State renderTick: number = 0;
  @State displayedStageLevel: number = 1;

  private readonly stages: CompanionStage[] = [
    {
      level: 1,
      title: '初遇陪伴',
      subtitle: '小猫刚住进你的学习空间，正悄悄观察主人的认真模样。',
      hint: '主人别着急，我会乖乖陪你把今天的小目标完成喵。',
      unlockText: '解锁基础陪伴动作',
      animationName: 'cat_sleep.json',
      accentColor: '#FFD29A',
      glowColor: 'rgba(255, 210, 154, 0.32)',
      badgeText: 'Lv.1 初遇',
      skinName: '奶油猫猫',
      talkLines: [
        '摸摸我之后，也要继续专心学习喵。',
        '我会安静陪着你，你认真看书就好喵。',
        '今天也一起把小目标慢慢做完吧，主人喵。',
        '主人别分心呀，我把尾巴借你当书签喵。',
        '你坐下来学习的时候，我就觉得今天会很棒喵。'
      ]
    },
    {
      level: 2,
      title: '熟悉陪学',
      subtitle: '你们慢慢熟悉起来了，小猫会用小动作回应主人的努力。',
      hint: '你一专心，我就想离你更近一点点喵。',
      unlockText: '解锁抖耳朵动作',
      animationName: 'black_cat_shake_ear.json',
      accentColor: '#B7C4D6',
      glowColor: 'rgba(183, 196, 214, 0.24)',
      badgeText: 'Lv.2 熟悉',
      skinName: '黑猫皮肤',
      talkLines: [
        '主人刚刚那一下好认真，我都看见啦喵。',
        '再坚持一会儿，我想看你完成这一轮喵。',
        '你这么努力，我也会更乖一点陪你喵。',
        '我耳朵都竖起来啦，因为主人状态超好喵。',
        '再学一点点，我就奖励你一个猫猫蹭蹭喵。'
      ]
    },
    {
      level: 3,
      title: '安心陪读',
      subtitle: '小猫已经很信任你，会安静地陪你沉浸学习。',
      hint: '主人坐好好学，我会趴在旁边等你完成这一轮喵。',
      unlockText: '解锁陪读形态',
      animationName: 'black_cat_sleep.json',
      accentColor: '#9FA9C9',
      glowColor: 'rgba(159, 169, 201, 0.24)',
      badgeText: 'Lv.3 陪读',
      skinName: '夜色黑猫',
      talkLines: [
        '别担心难题，我会一直在旁边守着你喵。',
        '你认真学习的样子，让猫猫很安心喵。',
        '安静一点没关系，我知道你正在变厉害喵。',
        '这一页翻过去，主人又会进步一点点喵。',
        '你专心的时候，连空气都变得乖乖的喵。'
      ]
    },
    {
      level: 4,
      title: '活力搭子',
      subtitle: '陪伴关系越来越亲密，小猫也变得更活泼啦。',
      hint: '做完任务记得回来找我，我想大声夸夸主人喵。',
      unlockText: '解锁活力动作',
      animationName: 'blue_cat_playball.json',
      accentColor: '#8ACBFF',
      glowColor: 'rgba(138, 203, 255, 0.26)',
      badgeText: 'Lv.4 活力',
      skinName: '晴空蓝猫',
      talkLines: [
        '主人今天超棒，再来一轮也没问题喵。',
        '我已经准备好继续陪你冲刺啦喵。',
        '做完这项任务，我就给你一个猫猫夸夸喵。',
        '冲呀主人，我已经替你把学习氛围踩热了喵。',
        '你的认真正在发光，我都想围着你转圈喵。'
      ]
    },
    {
      level: 5,
      title: '默契升级',
      subtitle: '你们越来越有默契，小猫已经懂你的学习节奏了。',
      hint: '你认真学习的样子最好看，猫猫会一直守着你喵。',
      unlockText: '解锁深海皮肤',
      animationName: 'blue_cat_sleep.json',
      accentColor: '#9EE2FF',
      glowColor: 'rgba(158, 226, 255, 0.26)',
      badgeText: 'Lv.5 默契',
      skinName: '深海蓝猫',
      talkLines: [
        '你一翻书，我就知道今天又要变厉害了喵。',
        '主人别急，慢慢来，我会一直守着你喵。',
        '今天的认真，我都替你悄悄记下来了喵。',
        '如果累了就看看我，我们再一起稳稳学下去喵。',
        '主人今天的节奏很好，猫猫给你点头认可喵。'
      ]
    },
    {
      level: 6,
      title: '专属陪伴',
      subtitle: '你们已经成为超稳定的陪学组合，猫猫最喜欢你啦。',
      hint: '今天也一起慢慢变厉害吧，我可是主人的专属小猫喵。',
      unlockText: '解锁限定动作',
      animationName: 'orange_cat_sleep_roll.json',
      accentColor: '#FFB26B',
      glowColor: 'rgba(255, 178, 107, 0.28)',
      badgeText: 'Lv.6 专属',
      skinName: '橘猫限定',
      talkLines: [
        '主人是我最喜欢的学习搭子喵。',
        '再摸摸我吧，摸完继续学习会更顺喵。',
        '你努力的每一小步，猫猫都会给你鼓掌喵。',
        '我已经是主人的专属陪学猫啦，要一起赢下今天喵。',
        '等你学完这一段，我就把今天的夸夸全送给你喵。'
      ]
    }
  ];

  private readonly catSounds: string[] = ['cat1.wav', 'cat2.wav', 'cat3.wav'];
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  private readonly animateName: string = 'companion_animation';
  private lottieDataCache: Map<string, Object> = new Map<string, Object>();
  private currentLoadedAnimation: string = '';
  private isLoading: boolean = false;
  private talkHideTimer: number = -1;
  private catSoundPlayer: media.AVPlayer | null = null;
  private catSoundState: media.AVPlayerState = 'idle';
  private isPreparingCatSound: boolean = false;

  aboutToAppear(): void {
    this.syncDisplayedStageLevel();
    void this.loadAnimation();
    this.currentTalkLine = this.stages[0].talkLines[0];
    void this.initCatSoundPlayer();
  }

  aboutToDisappear(): void {
    this.destroyAnimation();
    this.hideTalkBubbleImmediately();
    void this.releaseCatSoundPlayer();
  }

  private onProgressChange(): void {
    this.syncDisplayedStageLevel();
    this.renderTick = this.renderTick + 1;
    this.hideTalkBubbleImmediately();
    void this.loadAnimation();
  }

  private onTaskBoardChange(): void {
    this.renderTick = this.renderTick + 1;
  }

  private onStatsVersionChange(): void {
    this.syncDisplayedStageLevel();
    this.renderTick = this.renderTick + 1;
    void this.loadAnimation();
  }

  private destroyAnimation(): void {
    if (this.animateItem !== null) {
      lottie.destroy(this.animateName);
      this.animateItem = null;
    }
    this.currentLoadedAnimation = '';
  }

  private syncDisplayedStageLevel(): void {
    this.displayedStageLevel = this.companionProgress.level;
  }

  private getCurrentStage(): CompanionStage {
    for (let index = this.stages.length - 1; index >= 0; index--) {
      if (this.displayedStageLevel >= this.stages[index].level) {
        return this.stages[index];
      }
    }
    return this.stages[0];
  }

  private getAffinityProgress(): number {
    if (this.companionProgress.nextLevelAffinity <= 0) {
      return 1;
    }
    return Math.min(1, this.companionProgress.currentLevelAffinity / this.companionProgress.nextLevelAffinity);
  }

  private getAffinityProgressText(): string {
    if (this.companionProgress.level >= 6) {
      return '你们已经达到最高陪伴等级啦。';
    }
    const remain: number = Math.max(0, this.companionProgress.nextLevelAffinity - this.companionProgress.currentLevelAffinity);
    return `再获得 ${remain} 点默契值，就能解锁下一阶段喵。`;
  }

  private getStageAnimationName(): string {
    const stage: CompanionStage = this.getCurrentStage();
    return stage.animationName === '' ? this.animationName : stage.animationName;
  }

  private getClaimableCount(task: CompanionDailyTask): number {
    const available = Math.floor(task.progress / task.target) - task.claimedCount;
    return Math.max(0, available);
  }

  private getTaskProgressText(task: CompanionDailyTask): string {
    const cycleProgress = task.progress - task.claimedCount * task.target;
    const currentCycleProgress = Math.max(0, cycleProgress);
    return `当前 ${currentCycleProgress}/${task.target}`;
  }

  private getTaskStatusText(task: CompanionDailyTask): string {
    if (task.id === 'daily_login' && task.progress <= 0 && task.claimedCount <= 0) {
      return '去打卡';
    }
    const claimableCount = this.getClaimableCount(task);
    if (claimableCount > 0) {
      return '领取';
    }
    if (task.id === 'daily_login' && task.claimedCount > 0) {
      return '已完成';
    }
    if (task.claimedCount > 0) {
      return '已完成·可继续';
    }
    return '去完成';
  }

  private shouldNavigateTask(task: CompanionDailyTask): boolean {
    if (task.id === 'daily_login' && task.claimedCount > 0 && !this.canClaimTask(task)) {
      return false;
    }
    return true;
  }

  private shouldDirectClaimDailyLogin(task: CompanionDailyTask): boolean {
    return task.id === 'daily_login' && task.progress <= 0 && task.claimedCount <= 0;
  }

  private canClaimTask(task: CompanionDailyTask): boolean {
    return this.getClaimableCount(task) > 0;
  }

  private getTaskButtonFontColor(task: CompanionDailyTask): string {
    if (this.canClaimTask(task)) {
      return '#1A2432';
    }
    return '#F8FBFF';
  }

  private getTaskButtonBackground(task: CompanionDailyTask): string {
    if (this.canClaimTask(task)) {
      return this.accentColor;
    }
    if (task.claimedCount > 0) {
      return 'rgba(126,223,167,0.18)';
    }
    return 'rgba(255,255,255,0.10)';
  }

  private hideTalkBubbleImmediately(): void {
    this.talkBubbleVisible = false;
    this.talkBubbleOpacity = 0;
    this.talkBubbleScale = 0.9;
    if (this.talkHideTimer !== -1) {
      clearTimeout(this.talkHideTimer);
      this.talkHideTimer = -1;
    }
  }

  private showTalkBubble(): void {
    this.talkBubbleVisible = true;
    this.talkBubbleOpacity = 0;
    this.talkBubbleScale = 0.9;
    animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.talkBubbleOpacity = 1;
      this.talkBubbleScale = 1;
    });
    if (this.talkHideTimer !== -1) {
      clearTimeout(this.talkHideTimer);
    }
    this.talkHideTimer = setTimeout(() => {
      animateTo({ duration: 180, curve: Curve.EaseIn }, () => {
        this.talkBubbleOpacity = 0;
        this.talkBubbleScale = 0.95;
      });
      this.talkHideTimer = setTimeout(() => {
        this.talkBubbleVisible = false;
        this.talkHideTimer = -1;
      }, 200) as number;
    }, 2200) as number;
  }

  private async pickTalkLine(): Promise<void> {
    const stage: CompanionStage = this.getCurrentStage();
    const randomIndex: number = Math.floor(Math.random() * stage.talkLines.length);
    this.currentTalkLine = stage.talkLines[randomIndex];
    this.showTalkBubble();
    animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
      this.petScale = 1.06;
    });
    animateTo({ duration: 180, delay: 120, curve: Curve.EaseInOut }, () => {
      this.petScale = 1;
    });
    await this.playRandomCatSound();
  }

  private async ensureLottieData(fileName: string): Promise<void> {
    if (this.lottieDataCache.has(fileName) || this.isLoading) {
      return;
    }
    this.isLoading = true;
    try {
      const data: Uint8Array = getContext(this).resourceManager.getRawFileContentSync(fileName);
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const jsonString: string = decoder.decodeToString(new Uint8Array(data));
      this.lottieDataCache.set(fileName, JSON.parse(jsonString) as Object);
    } catch (error) {
      console.error(`[CompanionComponent] load raw lottie failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadAnimation(): Promise<void> {
    const fileName: string = this.getStageAnimationName();
    if (this.currentLoadedAnimation === fileName && this.animateItem !== null) {
      this.animateItem.play();
      return;
    }

    await this.ensureLottieData(fileName);
    const animationData: Object | undefined = this.lottieDataCache.get(fileName);
    if (animationData === undefined) {
      return;
    }

    this.destroyAnimation();
    this.currentLoadedAnimation = fileName;
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.animateName,
      contentMode: 'Contain',
      frameRate: 30,
      autoSkip: false,
      animationData: animationData
    });
    this.animateItem.addEventListener('DOMLoaded', () => {
      this.animateItem?.resize();
      this.animateItem?.play();
    });
  }

  private async initCatSoundPlayer(): Promise<void> {
    try {
      this.catSoundPlayer = await media.createAVPlayer();
      this.catSoundPlayer.on('stateChange', (state: media.AVPlayerState) => {
        this.catSoundState = state;
      });
    } catch (error) {
      console.error(`[CompanionComponent] init cat sound failed: ${JSON.stringify(error)}`);
    }
  }

  private async waitForCatSoundState(expectedState: media.AVPlayerState, timeoutMs: number = 1800): Promise<void> {
    const startTime = Date.now();
    while (this.catSoundState !== expectedState) {
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`wait cat sound state timeout: expected=${expectedState}, current=${this.catSoundState}`);
      }
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), 60);
      });
    }
  }

  private async stopCatSoundPlayback(): Promise<void> {
    if (this.catSoundPlayer === null) {
      return;
    }
    if (this.catSoundState === 'playing' || this.catSoundState === 'paused' || this.catSoundState === 'completed') {
      try {
        await this.catSoundPlayer.stop();
      } catch (error) {
        console.error(`[CompanionComponent] stop cat sound skipped: ${JSON.stringify(error)}`);
      }
    }
    if (this.catSoundState !== 'idle' && this.catSoundState !== 'released') {
      try {
        await this.catSoundPlayer.reset();
      } catch (error) {
        console.error(`[CompanionComponent] reset cat sound skipped: ${JSON.stringify(error)}`);
      }
    }
  }

  private async playRandomCatSound(): Promise<void> {
    if (this.catSoundPlayer === null || this.isPreparingCatSound) {
      return;
    }
    this.isPreparingCatSound = true;
    try {
      const soundName: string = this.catSounds[Math.floor(Math.random() * this.catSounds.length)];
      await this.stopCatSoundPlayback();
      const rawFd = await getContext(this).resourceManager.getRawFd(soundName);
      this.catSoundPlayer.fdSrc = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      await this.waitForCatSoundState('initialized');
      await this.catSoundPlayer.prepare();
      await this.waitForCatSoundState('prepared');
      await this.catSoundPlayer.play();
    } catch (error) {
      console.error(`[CompanionComponent] play cat sound failed: ${JSON.stringify(error)}`);
    } finally {
      this.isPreparingCatSound = false;
    }
  }

  private async releaseCatSoundPlayer(): Promise<void> {
    if (this.catSoundPlayer !== null) {
      try {
        await this.catSoundPlayer.release();
      } catch (error) {
        console.error(`[CompanionComponent] release cat sound failed: ${JSON.stringify(error)}`);
      }
      this.catSoundPlayer = null;
    }
  }

  build(): void {
    Stack() {
      Scroll() {
        this.buildContent(this.getCurrentStage())
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)

      if (this.showLevelUpModal) {
        this.buildLevelUpModal(this.getCurrentStage())
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildContent(stage: CompanionStage): void {
    Column({ space: 18 }) {
      Text(`${this.statsVersion}`)
        .width(0)
        .height(0)
        .opacity(0)

      Text(`${this.renderTick}`)
        .width(0)
        .height(0)
        .opacity(0)

      Column({ space: 10 }) {
        Text('陪学伙伴')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('90%')
          .textAlign(TextAlign.Start)
          .margin({ top: 24 })

        Text(stage.subtitle)
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.72)')
          .width('90%')
          .textAlign(TextAlign.Start)
          .lineHeight(22)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 14 }) {
        Row() {
          Text(`Lv.${this.companionProgress.level} ${stage.title}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Blank()

          Text(`${this.companionProgress.currentLevelAffinity}/${this.companionProgress.nextLevelAffinity} 默契值`)
            .fontSize(12)
            .fontColor(this.accentColor)
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('rgba(255,255,255,0.10)')
            .borderRadius(4)

          Row()
            .width(`${this.getAffinityProgress() * 100}%`)
            .height(8)
            .backgroundColor(this.accentColor)
            .borderRadius(4)
        }
        .width('100%')

        Text(this.getAffinityProgressText())
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.66)')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('rgba(255,255,255,0.08)')
      .border({
        width: 1,
        color: `${this.accentColor}22`
      })
      .borderRadius(24)

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('90%')
          .height(360)
          .borderRadius(32)
          .linearGradient({
            angle: 180,
            colors: [
              [stage.glowColor, 0],
              [`${this.accentColor}12`, 0.55],
              ['rgba(255,255,255,0.05)', 1]
            ]
          })

        Canvas(this.canvasRenderingContext)
          .width(300)
          .height(300)
          .scale({ x: this.petScale, y: this.petScale })
          .position({ x: '50%', y: '50%' })
          .translate({ x: -150, y: -118 })
          .onClick(() => {
            void this.pickTalkLine();
          })
          .onReady(() => {
            this.canvasRenderingContext.imageSmoothingEnabled = true;
            this.canvasRenderingContext.imageSmoothingQuality = 'medium';
            this.currentLoadedAnimation = '';
            void this.loadAnimation();
          })

        if (this.talkBubbleVisible && this.currentTalkLine !== '') {
          Column() {
            Text(this.currentTalkLine)
              .fontSize(13)
              .fontColor('#243244')
              .lineHeight(19)
              .textAlign(TextAlign.Start)
          }
          .width(188)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor('#FFF8E8')
          .borderRadius(18)
          .opacity(this.talkBubbleOpacity)
          .scale({ x: this.talkBubbleScale, y: this.talkBubbleScale })
          .shadow({
            radius: 18,
            color: 'rgba(0,0,0,0.12)',
            offsetX: 0,
            offsetY: 8
          })
          .position({ x: '8%', y: '18%' })
        }

        Column({ space: 8 }) {
          Text(stage.badgeText)
            .fontSize(12)
            .fontColor(this.accentColor)
            .fontWeight(FontWeight.Medium)

          Text(stage.skinName)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor('rgba(10,14,22,0.34)')
        .borderRadius(18)
        .position({ x: '50%', y: '82%' })
        .translate({ x: -55, y: 0 })
      }
      .width('100%')
      .height(360)

      Column({ space: 12 }) {
        Row() {
          Text('陪伴任务板')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Blank()
        }
        .width('100%')

        ForEach(this.dailyTasks, (task: CompanionDailyTask) => {
          Row({ space: 12 }) {
            Column({ space: 6 }) {
              Text(task.title)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .textAlign(TextAlign.Start)

              Text(task.description)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.64)')
                .width('100%')
                .textAlign(TextAlign.Start)
                .lineHeight(20)

              Row({ space: 8 }) {
                Text(`奖励 +${task.reward}`)
                  .fontSize(11)
                  .fontColor(this.accentColor)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(`${this.accentColor}20`)
                  .borderRadius(12)

                Text(this.getTaskProgressText(task))
                  .fontSize(11)
                  .fontColor('rgba(255,255,255,0.58)')
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Button(this.getTaskStatusText(task))
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getTaskButtonFontColor(task))
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.getTaskButtonBackground(task))
              .borderRadius(14)
              .onClick(() => {
                if (this.shouldDirectClaimDailyLogin(task)) {
                  this.onClaimTaskReward(task.id);
                } else if (this.canClaimTask(task)) {
                  this.onClaimTaskReward(task.id);
                } else if (this.shouldNavigateTask(task)) {
                  this.onGoToTask(task.id);
                }
              })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 14, bottom: 14 })
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(20)
        }, (task: CompanionDailyTask) => `${task.id}_${task.progress}_${task.claimedCount}`)
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('rgba(255,255,255,0.08)')
      .border({
        width: 1,
        color: `${this.accentColor}18`
      })
      .borderRadius(24)

      Row({ space: 12 }) {
        this.buildStatCard('连续天数', `${this.continuousDays} 天`, this.accentColor)
        this.buildStatCard('累计番茄', `${this.totalTomatoCount} 个`, this.accentColor)
        this.buildStatCard('今日完成', `${this.todayTomatoCount} 个`, this.accentColor)
      }
      .width('90%')

      Column({ space: 12 }) {
        this.buildInfoCard('当前皮肤', stage.skinName, '#FFFFFF')
        this.buildInfoCard('猫咪提醒', stage.hint, 'rgba(255,255,255,0.84)')
      }
      .width('90%')
      .margin({ bottom: 28 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildLevelUpModal(stage: CompanionStage): void {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(3,7,14,0.62)')

      Column({ space: 14 }) {
        Text('升级成功')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(`已解锁 ${this.unlockedStageTitle}`)
          .fontSize(15)
          .fontColor(this.accentColor)

        Text(this.unlockedStageReward)
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.72)')
          .textAlign(TextAlign.Center)
          .lineHeight(22)

        Text(`当前皮肤：${stage.skinName}`)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('rgba(255,255,255,0.08)')
          .borderRadius(14)

        Text(stage.unlockText)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.64)')

        Button('我知道啦')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A2432')
          .height(42)
          .padding({ left: 24, right: 24 })
          .backgroundColor(this.accentColor)
          .borderRadius(21)
          .onClick(() => {
            this.onDismissLevelUp();
          })
      }
      .width('76%')
      .padding({ left: 18, right: 18, top: 24, bottom: 24 })
      .backgroundColor('rgba(18,24,34,0.96)')
      .border({
        width: 1,
        color: this.accentColor
      })
      .borderRadius(28)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildStatCard(title: string, value: string, accentColor: string): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.60)')

      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(accentColor)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(24)
  }

  @Builder
  private buildInfoCard(title: string, content: string, accentColor: string): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.58)')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(content)
        .fontSize(16)
        .fontColor(accentColor)
        .width('100%')
        .textAlign(TextAlign.Start)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(22)
  }
}
