using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InstanceRolling : MonoBehaviour
{
    [Header("创建特效")]
    public GameObject efffect;

    [Header("北方")]
    public bool disableN;
    public Vector3 northArea;
    public Vector3 northCenter;
    [Header("南方")]
    public bool disableS;
    public Vector3 southArea;
    public Vector3 southCenter;
    [Header("西方")]
    public bool disableW;
    public Vector3 westArea;
    public Vector3 westCenter;
    [Header("东方")]
    public bool disableE;
    public Vector3 eastArea;
    public Vector3 eastCenter;
    private Vector3 targetArea;
    private Vector3 targetCenter;
    private int targetIndex;


    [Header("生成时间间隔（min/max）")]
    public Vector2 minMax;
    private float durTime;

    [Header("草球")]
    public GameObject rollingGrass;
    public float force;
    
    bool ableToDrop;

    // Start is called before the first frame update
    void Start()
    {    
        ableToDrop = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (PlayerIndentify.isStartGame)
        {
            InstanceRollingGrass();
        }
    }

    void InstanceRollingGrass()
    {
        if (ableToDrop)
        {
            
            targetIndex = Random.Range(1, 4);
            if (targetIndex == 1&&!disableN)//北
            {
                GameObject grassball;
                targetArea.x = Random.Range((northCenter.x - northArea.x/2), (northCenter.x + northArea.x/2));
                targetArea.y = Random.Range((northCenter.y - northArea.y/2), (northCenter.y + northArea.y/2));
                targetArea.z = Random.Range((northCenter.z - northArea.z/2), (northCenter.z + northArea.z/2));
                grassball=Instantiate(rollingGrass, targetArea, Quaternion.identity);
                Instantiate(efffect, targetArea, Quaternion.identity);
                grassball.GetComponent<Rigidbody>().AddForce(new Vector3(0, 0, -1) * force, ForceMode.Impulse);
                grassball.GetComponent<GrassRotate>().index = 1;
                ableToDrop = false;
                durTime = Random.Range(minMax.x, minMax.y);
                StartCoroutine(WaitToDrop(durTime));
            }

            if (targetIndex == 2&&!disableS)//南
            {
                GameObject grassball;
                targetArea.x = Random.Range((southCenter.x - southArea.x / 2), (southCenter.x + southArea.x / 2));
                targetArea.y = Random.Range((southCenter.y - southArea.y / 2), (southCenter.y + southArea.y / 2));
                targetArea.z = Random.Range((southCenter.z - southArea.z / 2), (southCenter.z + southArea.z / 2));
                grassball=Instantiate(rollingGrass, targetArea, Quaternion.identity);
                Instantiate(efffect, targetArea, Quaternion.identity);
                grassball.GetComponent<Rigidbody>().AddForce(new Vector3(0, 0, 1) * force, ForceMode.Impulse);
                grassball.GetComponent<GrassRotate>().index = 2;
                ableToDrop = false;
                durTime = Random.Range(minMax.x, minMax.y);
                StartCoroutine(WaitToDrop(durTime));
            }

            if (targetIndex == 3&&!disableW)//西
            {
                GameObject grassball;
                targetArea.x = Random.Range((westCenter.x - westArea.x / 2), (westCenter.x + westArea.x / 2));
                targetArea.y = Random.Range((westCenter.y - westArea.y / 2), (westCenter.y + westArea.y / 2));
                targetArea.z = Random.Range((westCenter.z - westArea.z / 2), (westCenter.z + westArea.z / 2));
                grassball = Instantiate(rollingGrass, targetArea, Quaternion.identity);
                Instantiate(efffect, targetArea, Quaternion.identity);
                grassball.GetComponent<Rigidbody>().AddForce(new Vector3(1,0,0)*force, ForceMode.Impulse);
                grassball.GetComponent<GrassRotate>().index = 3;
                ableToDrop = false;
                durTime = Random.Range(minMax.x, minMax.y);
                StartCoroutine(WaitToDrop(durTime));
            }
            if (targetIndex == 4&&!disableE)//东
            {
                GameObject grassball;
                targetArea.x = Random.Range((eastCenter.x - eastArea.x / 2), (eastCenter.x + eastArea.x / 2));
                targetArea.y = Random.Range((eastCenter.y - eastArea.y / 2), (eastCenter.y + eastArea.y / 2));
                targetArea.z = Random.Range((eastCenter.z - eastArea.z / 2), (eastCenter.z + eastArea.z / 2));
                grassball = Instantiate(rollingGrass, targetArea, Quaternion.identity);
                Instantiate(efffect, targetArea, Quaternion.identity);
                grassball.GetComponent<Rigidbody>().AddForce(new Vector3(-1, 0, 0) * force,ForceMode.Impulse);
                grassball.GetComponent<GrassRotate>().index = 4;
                ableToDrop = false;
                durTime = Random.Range(minMax.x, minMax.y);
                StartCoroutine(WaitToDrop(durTime));
            }
        }
    }
    IEnumerator WaitToDrop(float durTime)
    {
        yield return new WaitForSeconds(durTime);
        ableToDrop = true;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireCube(eastCenter,eastArea);
        Gizmos.DrawWireCube(westCenter,westArea);
        Gizmos.DrawWireCube(southCenter, southArea);
        Gizmos.DrawWireCube(northCenter, northArea);
    }
}
