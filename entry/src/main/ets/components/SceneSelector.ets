import { SceneData } from '../common/StudyRoomTypes';

@Component
export struct SceneSelector {
  @Prop scenes: SceneData[] = [];
  @Prop currentSceneIndex: number = 0;
  onSceneChange: (index: number) => void = () => {};

  build() {
    Column() {
      if (this.scenes.length > 0) {
        Row() {
          ForEach(this.scenes, (scene: SceneData, index: number) => {
            Text(scene.name)
              .fontSize(14)
              .fontColor(this.currentSceneIndex === index ? '#FFD878' : '#FFFFFF')
              .fontWeight(this.currentSceneIndex === index ? FontWeight.Bold : FontWeight.Normal)
              .width('33%')
              .height(44)
              .textAlign(TextAlign.Center)
              .borderRadius(22)
              .backgroundColor(this.currentSceneIndex === index ? 'rgba(255,216,120,0.25)' : 'rgba(255,255,255,0.1)')
              .onClick(() => {
                this.onSceneChange(index);
              })
          })
        }
        .width('90%')
        .margin({ top: 16, bottom: 12 })

        Text(this.scenes[this.currentSceneIndex].atmosphere)
          .fontSize(12)
          .fontColor('#E0E0E0')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor('rgba(0,0,0,0.2)')
          .borderRadius(40)
          .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
