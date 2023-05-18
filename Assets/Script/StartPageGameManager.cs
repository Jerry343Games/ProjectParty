using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StartPageGameManager : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject firstPanel;
    public GameObject secondPanel;
    public GameObject devPanel;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ClikStartModel()
    {
        firstPanel.GetComponent<UIFade>().UI_FadeOut_Event();
        secondPanel.GetComponent<UIFade>().UI_FadeIn_Event();
    }

    public void ClikDevButton()
    {
        firstPanel.GetComponent<UIFade>().UI_FadeOut_Event();
        devPanel.GetComponent<UIFade>().UI_FadeIn_Event();
    }

    public void ClickCloseDevButton()
    {
        firstPanel.GetComponent<UIFade>().UI_FadeIn_Event();
        devPanel.GetComponent<UIFade>().UI_FadeOut_Event();
    }

    public void ClickCloseSecButton()
    {
        secondPanel.GetComponent<UIFade>().UI_FadeOut_Event();
        firstPanel.GetComponent<UIFade>().UI_FadeIn_Event();
    }

    public void Click2Model()
    {
        SceneManager.LoadScene("RopeTest 2");
    }

    public void Click3Model()
    {
        SceneManager.LoadScene("RopeTest");
    }
    public void Click4Model()
    {
        SceneManager.LoadScene("RopeTest 4");
    }

    public void ClickExit()
    {
        Application.Quit();
    }
}
