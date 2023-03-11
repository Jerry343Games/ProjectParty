using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StartPageGameManager : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void Click2Model()
    {
        SceneManager.LoadScene("Scene_2p_0");
    }

    public void Click3Model()
    {
        SceneManager.LoadScene("RopeTest");
    }

    public void ClickExit()
    {
        Application.Quit();
    }
}
