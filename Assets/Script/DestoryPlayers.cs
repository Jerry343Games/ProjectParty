using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestoryPlayers : MonoBehaviour
{
    // Start is called before the first frame update
    private GameObject p0;
    private GameObject p1;
    private GameObject p2;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (p0 = GameObject.Find("Player 0"))
        {
            Destroy(p0);
        }
        if (p1 = GameObject.Find("Player 1"))
        {
            Destroy(p1);
        }
        if (p2 = GameObject.Find("Player 2"))
        {
            Destroy(p2);
        }
    }
}
