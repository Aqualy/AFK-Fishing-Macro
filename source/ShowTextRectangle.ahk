;==================================================================================
; 파일명 : ShowTextRectangle.ahk
; 설명 : 화면 특정 영역 표시 라이브러리
; 버전: v1.0
; 라이센스: CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/deed.ko)
; 설치방법: #Include ShowTextRectangle.ahk
; 제작자: https://catlab.tistory.com/ (fty816@gmail.com)
;==================================================================================

#Include Gdip_All.ahk

class ShowTextRectangle
{
	;==================================================================================
	; 객체생성 :
	; Obj := new ShowTextRectangle()
	; 영역표시 :
	; Obj.Show(X, Y, W, H, [Text], [BackgroundColor], [TextColor])
	; 영역제거 :
	; Obj.Hide()
	; 객체제거 :
	; Obj.__Delete()
	;==================================================================================

	__New()
	{
		this.Width := A_ScreenWidth, this.Height := A_ScreenHeight
		Gui,Rec: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
		Gui,Rec: Show, NA

		this.pToken := Gdip_Startup()

		this.HWND := WinExist()
		this.hbm := CreateDIBSection(this.Width, this.Height)
		this.hdc := CreateCompatibleDC()
		this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc)
		Gdip_SetSmoothingMode(this.G, 4)
	}

	Show(X, Y, W, H, Text:="", BackgroundColor:="000000", TextColor:="FFFFFF")
	{
		this.Brush := Gdip_BrushCreateSolid("0xFF" BackgroundColor)
		this.Pen := Gdip_CreatePen("0xFF" BackgroundColor, 3)

		Gdip_DrawRectangle(this.G, this.Pen, X, Y, W, H)
		Gdip_FillRectangle(this.G, this.Brush, X-1, Y-30, this.TextRecLen(Text), 30)

		OPTIONS := "X" X "Y" Y-30 "CFF" TextColor "R4 S20 Bold"
		Gdip_TextToGraphics(this.G, Text, OPTIONS, "Segoe UI")

		UpdateLayeredWindow(this.HWND, this.hdc, 0, 0, this.Width, this.Height)
	}

	TextRecLen(Text)
	{
		Loop, Parse, Text
			Length += ((Asc(A_LoopField) > 44031 && Asc(A_LoopField) < 55204) || (Asc(A_LoopField) > 12592 && Asc(A_LoopField) < 12686)) ? 22 : 15

		return Length
	}

	Hide()
	{
		Gdip_DeleteBrush(this.Brush)
		Gdip_DeletePen(this.Pen)

		Gdip_GraphicsClear(this.G)
		UpdateLayeredWindow(this.HWND, this.hdc, 0, 0, this.Width, this.Height)
	}

	__Delete()
	{
		Gui,Rec: Destroy
		Gdip_DeleteGraphics(this.G)
		Gdip_DeleteBrush(this.Brush)
		Gdip_DeletePen(this.Pen)

		SelectObject(this.hdc, this.obm)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)

		Gdip_Shutdown(this.pToken)
	}
}