import { SceneData } from '../common/StudyRoomTypes';

@Component
export struct SceneSelector {
  @Prop scenes: SceneData[] = [];
  @Prop currentSceneIndex: number = 0;
  onSceneChange: (index: number) => void = () => {};
  onRandomScene: () => void = () => {};

  build() {
    Column() {
      if (this.scenes.length > 0) {
        // 标题 + 随机按钮
        Row() {
          Text('今日自习室')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
          Blank()
          Button('随机进入')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .height(32)
            .backgroundColor('rgba(255,255,255,0.16)')
            .borderRadius(16)
            .onClick(() => {
              this.onRandomScene();
            })
        }
        .width('90%')
        .margin({ top: 16, bottom: 10 })

        // 三个场景卡片
        Row() {
          ForEach(this.scenes, (scene: SceneData, index: number) => {
            Column() {
              Text(scene.name)
                .fontSize(14)
                .fontColor(this.currentSceneIndex === index ? '#FFFFFF' : '#F3F3F3')
                .fontWeight(this.currentSceneIndex === index ? FontWeight.Bold : FontWeight.Normal)
              Text(scene.suggestion)
                .fontSize(10)
                .fontColor(this.currentSceneIndex === index ? '#FFF8D8' : '#D8D8D8')
                .maxLines(1)
                .margin({ top: 4 })
            }
            .width('32%')
            .height(62)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 8, right: 8 })
            .borderRadius(22)
            .backgroundColor(this.currentSceneIndex === index ? scene.accentColor : 'rgba(255,255,255,0.10)')
            .onClick(() => {
              this.onSceneChange(index);
            })
          })
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}