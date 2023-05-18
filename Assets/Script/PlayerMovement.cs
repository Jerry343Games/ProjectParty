using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
//using UnityEditor;
using UnityEngine.UI;

public class PlayerMovement : MonoBehaviour
{
    [Header("Player Move")]
    public float moveSpeed;
    Vector2 movent;

    [Header("Control Model Rotate")]
    public GameObject playerModel;
    private Transform modelPos;

    [Header("Aiming & Shooting")]
    public GameObject aimingArrow;
    public LayerMask groundMask;
    public GameObject bulletPrefab;
    public GameObject bulletPrefabFire;
    bool ableAim;
    public bool ableMove;
    
    Vector2 rotate;
    Vector2 mousePosition;
    private float aimKeyValue=0f;
    bool hasHold=false;
    private float percent;

    [Header("CreatRope")]
    public float ropeKeyValue = 0f;
    //public static float releaseKeyValue=0f;
    public GameObject circle;
    //测试正方体
    //public GameObject testCube;

    [Header("InputSystem")]
    PlayerInput playerInput;
    public Material[] modelMat;
    public Material[] arrowMat;
    public Material[] circleMat;
    public GameObject ColdCirleMat;
    public Transform[] resetPoints;
    int playerNum;

    [Header("CreatRop")]
    bool hasFind;
    bool ropeCreated;
    bool creatButtonPress;
    GameObject rope01;
    GameObject rope02;
    GameObject rope12;
    public static bool linked01;
    public static bool linked02;
    public static bool linked12;

    private float coldTime;
    Rigidbody rb;
    public Animator playerAni;

    private GameObject cb;
    public GameObject cb1;
    public GameObject cb2;
    public GameObject cb3;
    public GameObject cb4;
    bool rotateMode;
    Vector3 cbDir;

    // Start is called before the first frame update
    void Start()
    {
        DontDestroyOnLoad(this.gameObject);
        hasFind = false;
        ropeCreated = false;
        creatButtonPress = false;
        ableAim = true;
        ableMove = true;
        rotateMode = false;
    }

    private void Awake()
    {
        rb = playerModel.GetComponent<Rigidbody>();
        //再在每关写一个探测玩家并传送的脚本
        playerInput = GetComponent<PlayerInput>();
        playerNum = playerInput.playerIndex;
        if (playerNum == 0)
        {
            gameObject.name = "Player 0";
            playerModel.GetComponent<MeshRenderer>().material=modelMat[0];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[0];
            circle.GetComponent<MeshRenderer>().material = circleMat[0];
            cb1.SetActive(true);
            cb = cb1;
            cb2.SetActive(false);
            cb3.SetActive(false);
            cb4.SetActive(false);
            transform.position = resetPoints[0].position;
            playerAni = cb1.GetComponent<Animator>();
        }
        if (playerNum == 1)
        {
            gameObject.name = "Player 1";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[1];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[1];
            circle.GetComponent<MeshRenderer>().material = circleMat[1];
            cb1.SetActive(false);
            cb2.SetActive(true);
            cb = cb2;
            cb3.SetActive(false);
            cb4.SetActive(false);
            transform.position = resetPoints[1].position;
            playerAni = cb2.GetComponent<Animator>();
        }
        if (playerNum == 2)
        {
            gameObject.name = "Player 2";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[2];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[2];
            circle.GetComponent<MeshRenderer>().material = circleMat[2];
            cb1.SetActive(false);
            cb2.SetActive(false);
            cb3.SetActive(true);
            cb = cb3;
            cb4.SetActive(false);
            transform.position = resetPoints[2].position;
            playerAni = cb3.GetComponent<Animator>();
        }
        if (playerNum == 3)
        {
            gameObject.name = "Player 3";
            playerModel.GetComponent<MeshRenderer>().material = modelMat[3];
            aimingArrow.GetComponent<MeshRenderer>().material = arrowMat[3];
            circle.GetComponent<MeshRenderer>().material = circleMat[3];
            cb1.SetActive(false);
            cb2.SetActive(false);
            cb3.SetActive(false);
            cb4.SetActive(true);
            cb = cb4;
            transform.position = resetPoints[3].position;
            playerAni = cb4.GetComponent<Animator>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        //FindRope();

        if (PlayerIndentify.isStartGame)
        {
            if (ableMove&& playerModel.GetComponent<GraspMilkBox>().ableMove)
            {
                PlayerMove();
            }
            Aiming();
            //LinkRope();
        }
        ColdCircle(coldTime);

        if (playerModel.GetComponent<GraspMilkBox>().isGrasping)
        {
            playerAni.SetBool("hold", true);
        }
        else {
            playerAni.SetBool("hold", false);
        }

        if (rotateMode)
        {
            cb.transform.LookAt(cbDir, Vector3.up);
        }

    }


    //监听双设备移动输入
    public void OnMove(InputAction.CallbackContext value0)
    {
        movent = value0.ReadValue<Vector2>();
    }
    //监听手柄旋转瞄准输入
    public void OnRotate(InputAction.CallbackContext value)
    {
        rotate = value.ReadValue<Vector2>();
    }
    //监听鼠标瞄准输入
    public void OnMouseRotate(InputAction.CallbackContext value)
    {
        mousePosition = value.ReadValue<Vector2>();
        //Debug.Log("Mouse Position" + mousePosition);
    }
    //监听手柄瞄准键
    public void OnAim(InputAction.CallbackContext value)
    {
        //getShoulderDown = value.ReadValue<bool>();
        aimKeyValue = value.ReadValue<float>();
        //Debug.Log("Mouse");
    }
    //监测链接键输入
    public void OnCreatRope(InputAction.CallbackContext value)
    {
        ropeKeyValue = value.ReadValue<float>();
        //releaseKeyValue = ropeKeyValue;
        //Debug.Log("!!!!!!!!!!!!!!!!!!!!!"+ropeKeyValue);
    }


    //双设备移动
    private void PlayerMove()
    {
        rb.MovePosition( new Vector3(rb.position.x+movent.x * Time.deltaTime * moveSpeed, rb.position.y, rb.position.z+ movent.y * Time.deltaTime * moveSpeed));
        if (movent != Vector2.zero)
        {
            playerAni.SetBool("run", true);
        }
        if (movent == Vector2.zero)
        {
            playerAni.SetBool("run", false);
        }
        //transform.Translate(new Vector3(movent.x, 0f, movent.y) * Time.deltaTime * moveSpeed);
        if (!rotateMode)
        {
            playerModel.transform.LookAt(new Vector3(playerModel.transform.position.x + movent.x, playerModel.transform.position.y, playerModel.transform.position.z + movent.y), Vector3.up);
            cb.transform.LookAt(new Vector3(cb.transform.position.x + movent.x, cb.transform.position.y, cb.transform.position.z + movent.y), Vector3.up);
        }
        if (rotateMode)
        {
            
        }
    }

    //手柄瞄准
    private void Aiming()
    {
        if (ableAim&&!playerModel.GetComponent<GraspMilkBox>().isGrasping)
        {
            //Debug.Log(aimKeyValue);
            if (aimKeyValue == 1f)
            {
                aimingArrow.SetActive(true);
                MouseAming();
                aimingArrow.transform.LookAt(new Vector3(aimingArrow.transform.position.x + rotate.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z + rotate.y), Vector3.up);
                cbDir = new Vector3(cb.transform.position.x + rotate.x, cb.transform.position.y, cb.transform.position.z + rotate.y);
                hasHold = true;
                coldTime = 1;
            }
            if (aimKeyValue == 0f && hasHold)
            {
                hasHold = false;
                Debug.Log("Fire");
                if (!playerModel.GetComponent<GraspMilkBox>().isGraspGun)
                {
                    Instantiate(bulletPrefab, new Vector3(aimingArrow.transform.position.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z), aimingArrow.transform.rotation);
                    aimingArrow.SetActive(false);
                    ableAim = false;
                    ableMove = false;
                    coldTime = 1f;
                    rb.velocity = Vector3.zero;
                    rotateMode = true;
                    StartCoroutine(WaitFireColdTime(1f));
                    StartCoroutine(WaitFireMoveTime());
                    
                }
                if (playerModel.GetComponent<GraspMilkBox>().isGraspGun)
                {
                    SoundsManager.PlayThrowAudio();
                    Instantiate(bulletPrefabFire, new Vector3(aimingArrow.transform.position.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z), aimingArrow.transform.rotation);                   
                    aimingArrow.SetActive(false);
                    ableAim = false;
                    coldTime = 2f;
                    StartCoroutine(WaitFireColdTime(2f));
                }
            }
        }

        if (playerModel.GetComponent<GraspMilkBox>().isGraspGun)
        {
            //Debug.Log(aimKeyValue);
            if (aimKeyValue == 1f)
            {
                aimingArrow.SetActive(true);
                MouseAming();
                aimingArrow.transform.LookAt(new Vector3(aimingArrow.transform.position.x + rotate.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z + rotate.y), Vector3.up);
                cbDir = new Vector3(cb.transform.position.x + rotate.x, cb.transform.position.y, cb.transform.position.z + rotate.y);
                hasHold = true;
                coldTime = 1;
            }
            if (aimKeyValue == 0f && hasHold)
            {
                hasHold = false;
                Debug.Log("Fire");
                if (!playerModel.GetComponent<GraspMilkBox>().isGraspGun)
                {
                    Instantiate(bulletPrefab, new Vector3(aimingArrow.transform.position.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z), aimingArrow.transform.rotation);
                    
                    aimingArrow.SetActive(false);
                    ableAim = false;
                    ableMove = false;
                    coldTime = 1f;
                    rb.velocity = Vector3.zero;
                    rotateMode = true;
                    StartCoroutine(WaitFireColdTime(1f));
                    StartCoroutine(WaitFireMoveTime());

                }
                if (playerModel.GetComponent<GraspMilkBox>().isGraspGun)
                {
                    SoundsManager.PlayFireAudio();
                    MilkBoxSettings.bulletRemain--;
                    Debug.Log("Remain:" + MilkBoxSettings.bulletRemain);
                    Instantiate(bulletPrefabFire, new Vector3(aimingArrow.transform.position.x, aimingArrow.transform.position.y, aimingArrow.transform.position.z), aimingArrow.transform.rotation);
                    aimingArrow.SetActive(false);
                    ableAim = false;
                    coldTime = 2f;
                    StartCoroutine(WaitFireColdTime(2f));
                }
            }
        }
    }

    IEnumerator WaitFireColdTime(float time)
    {
        yield return new WaitForSeconds(time);
        ableAim = true;
    }
    IEnumerator WaitFireMoveTime()
    {
        yield return new WaitForSeconds(0.4f);
        cb.transform.rotation = Quaternion.Euler(0, 0, 0);
        ableMove = true;
        rotateMode = false;
    }

    //冷却圆环控制
    private void ColdCircle(float t)
    {
        if (!ableAim) {
            percent = ColdCirleMat.GetComponent<Renderer>().material.GetFloat("_Percent");
            percent += Time.deltaTime * (1 / t);
            ColdCirleMat.GetComponent<Renderer>().material.SetFloat("_Percent", percent);
            //Debug.Log(percent);
        }
        if (ableAim)
        {
            percent = 0;
            ColdCirleMat.GetComponent<Renderer>().material.SetFloat("_Percent", percent);
        }
    }

    //创建绳子
    private void LinkRope()
    {
        if (PlayerIndentify.staticTotalNum == 3)//3玩家
        {
            if (ropeKeyValue == 1 && !ropeCreated && !creatButtonPress)
            {
                if (PlayerIndentify.link0_1 && (playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(true);
                    linked01=true;
                }
                else if (PlayerIndentify.link0_2 && (playerNum == 0 || playerNum == 2))
                {
                    rope02.SetActive(true);
                    linked02 = true;
                }
                else if (PlayerIndentify.link1_2 && (playerNum == 1 || playerNum == 2))
                {
                    rope12.SetActive(true);
                    linked12 = true;
                }
                else
                {
                    return;
                }
                ropeCreated = true;
                creatButtonPress = true;
            }
            if (ropeKeyValue == 0 && creatButtonPress)
            {
                creatButtonPress = false;
            }

            if (ropeCreated && !creatButtonPress && ropeKeyValue == 1)
            {
                Debug.Log("Release");
                if ((playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(false);
                    linked01 = false;
                }
                if ((playerNum == 0 || playerNum == 2))
                {
                    rope02.SetActive(false);
                    linked02 = false;
                }
                if ((playerNum == 1 || playerNum == 2))
                {
                    rope12.SetActive(false);
                    linked12 = false;
                }
                creatButtonPress = true;
                ropeCreated = false;
            }
        }
        if (PlayerIndentify.staticTotalNum == 2)//2玩家
        {
            if (ropeKeyValue == 1 && !ropeCreated && !creatButtonPress)
            {
                if (PlayerIndentify.link0_1 && (playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(true);
                }
                ropeCreated = true;
                creatButtonPress = true;
            }
            if (ropeKeyValue == 0 && creatButtonPress)
            {
                creatButtonPress = false;
            }
            if (ropeCreated && !creatButtonPress && ropeKeyValue == 1)
            {
                Debug.Log("Release");
                if ((playerNum == 0 || playerNum == 1))
                {
                    rope01.SetActive(false);
                }
                creatButtonPress = true;
                ropeCreated = false;
            }
        }
    }
    //寻找绳子
    private void FindRope()
    {
        if (PlayerIndentify.isStartGame && !hasFind)
        {
            if (PlayerIndentify.staticTotalNum == 3)
            {
                rope01 = FindObject2("Ropes", "Rope 0-1");
                rope02 = FindObject2("Ropes", "Rope 0-2");
                rope12 = FindObject2("Ropes", "Rope 1-2");
                hasFind = true;
            }

            if (PlayerIndentify.staticTotalNum == 2)
            {
                rope01 = FindObject2("Ropes", "Rope 0-1");
                hasFind = true;
            }

        }
    }

    //鼠标瞄准
    private void MouseAming()
    {
        var (success, position) = GetMousePosition();
        if (success)
        {
            // Calculate the direction
            var direction = position - aimingArrow.transform.position;

            // You might want to delete this line.
            // Ignore the height difference.
            direction.y = 0;
            //Debug.Log(direction);
            // Make the transform look in the direction.
            aimingArrow.transform.forward = direction;
        }
        else
        {
            Debug.LogWarning("Get Mouse Position False");
        }
    }
    
    //鼠标瞄准射线转换
    public (bool success, Vector3 position) GetMousePosition()
    {
        var ray = Camera.main.ScreenPointToRay(mousePosition);
       // Debug.Log(Camera.main.transform.position);


        if (Physics.Raycast(ray, out var hitInfo, Mathf.Infinity, 1<< LayerMask.NameToLayer("Ground")))
        {
            // The Raycast hit something, return with the position.
            return (success: true, position: hitInfo.point);
        }
        else
        {
            // The Raycast did not hit anything.
            Debug.LogWarning("Raycast Empty");
            return (success: false, position: Vector3.zero);
            
        }
    }
    private static GameObject FindObject2(string parentName,string childName)
    {
        GameObject parentObj = GameObject.Find(parentName);
        GameObject bbb = parentObj.transform.Find(childName).gameObject;
        return bbb;
    }


    public void PlayerDizziness(float dizTime)
    {
        ableAim = false;
        ableMove = false;
        coldTime = dizTime;
        StartCoroutine(WaitToDisableDiz(dizTime));
    }

    IEnumerator WaitToDisableDiz(float dizTime)
    {
        yield return new WaitForSeconds(dizTime);
        ableMove = true;
        ableAim = true;
    }

}
